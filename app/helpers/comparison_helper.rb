module ComparisonHelper

  # need it in order to capture the benchmark details
  include CaptureSdout

  ######### Paginations
  # To be fair with all gems, we postpone the controller code in the view,
  # so we can put the whole process to benchmark in one single block.
  # We need that because collection-extraction and navigation-display
  # happen at different times for different gems, and they include the helpers in the views.
  # We use the following *_pagination methods for memory profiling and benchmarks
  # They are doing exactly the same thing, just with a different gem.


  def pagy_pagination(scope=Dish.all, page=params[:page])
    pagy, records = pagy(scope, page: page)
    pagy_nav_bootstrap(pagy)
    pagy_info(pagy)
  end

  def will_paginate_pagination(scope=Dish.all, page=params[:page])
    records = scope.page(page)
    will_paginate records, outer_window: 4, page_links: true, :renderer => WillPaginate::ActionView::Bootstrap4LinkRenderer
    page_entries_info(records)
  end

  def kaminari_pagination(scope=Dish.all, page=params[:page])
    records = scope.kaminari_page(page)
    paginate records
    kaminari_page_entries_info(records)
  end



  ######### Code Size

  def init_code_size
    return unless Rails.env.production?
    # pagy
    $p.code_size = CodeSize.new paths: [File.join(`bundle show pagy`.strip, 'lib')]
    # will_paginate
    paths = [ File.join(`bundle show will_paginate`.strip, 'lib'),
              File.join(`bundle show bootstrap-will_paginate`.strip, 'lib'),
              File.join(`bundle show bootstrap-will_paginate`.strip, 'config') ]
    $w.code_size = CodeSize.new paths: paths
    # kaminari
    paths = %w[kaminari kaminari-core kaminari-actionview kaminari-activerecord].map do |gem|
      File.join(`bundle show #{gem}`.strip, 'lib')
    end
    # kaminari templates
    paths << File.join(`bundle show kaminari-core`.strip, 'app', 'views', 'kaminari').to_s
    # kaminari bootstrap templates
    paths << Rails.root.join('app', 'views', 'kaminari').to_s
    $k.code_size = CodeSize.new paths: paths, ext: '{rb,erb}', exclude: [/^generators/]
  end

  def loc_chart_data
    data = [['','Lines Of Code', {role: 'annotation'}]]
    p,w,k = [$p,$w,$k].map{ |o| o.code_size.loc_count }
    data << ['Pagy',          p, ratio_annot(w, p, :less)]
    data << ['Will Paginate', w, ratio_annot(w, p, :more)]
    data << ['Kaminari',      k, ratio_annot(k, p, :more)]
  end

  def files_chart_data
    data = [['Item', 'Parent', 'LOC'], [ 'Gems', nil, 0], ['Pagy', 'Gems', 0], ['Will Paginate', 'Gems', 0], ['Kaminari', 'Gems', 0]]
    line = -> (label, files){ files.each{|f| data << [f[:name], label, f[:loc]] } }
    line.call('Pagy',          $p.code_size.uniq_name_files)
    line.call('Will Paginate', $w.code_size.uniq_name_files)
    line.call('Kaminari',      $k.code_size.uniq_name_files)
    data
  end



  ######### Code Struct

  def init_code_struct
    return unless Rails.env.production?
    $p.code_struct = CodeStruct.new Pagy
    $w.code_struct = CodeStruct.new WillPaginate
    $k.code_struct = CodeStruct.new Kaminari
  end

  def methods_chart_data
    data = [['', 'Methods', {role: 'annotation'}]]
    p,w,k = [$p,$w,$k].map{ |o| o.code_struct.method_count }
    data << ['Pagy',          p, ratio_annot(k, p, :less)]
    data << ['Will Paginate', w, ratio_annot(w, p, :more)]
    data << ['Kaminari',      k, ratio_annot(k, p, :more)]
  end

  def modules_chart_data
    data = [['Item', 'Parent', 'Methods'], [ 'Gems', nil, 0], ['Pagy', 'Gems', 0], ['Will Paginate', 'Gems', 0], ['Kaminari', 'Gems', 0]]
    line = -> (label, mod_meth){ mod_meth.each{|m| data << [m[:name]+' ', label, m[:methods].size] } }
    line.call('Pagy',          $p.code_struct.modules)
    line.call('Will Paginate', $w.code_struct.modules)
    line.call('Kaminari',      $k.code_struct.modules)
    data
  end



  ######## Memory Profile

  def init_memory
    return unless Rails.env.production?
    # memory stats need warmup because at the first pagination after the server startup
    # the gems seem to allocate more memory (e.g. just a few Kb more for Pagy but
    # 1Mb for Kaminari and 53Mb for Will Paginate!!!)
    pagy_pagination
    will_paginate_pagination
    kaminari_pagination

    # In practice we profile the memory at the second execution of the pagination
    $p.memory = MemoryProfile.new profile_for(:pagy)
    $w.memory = MemoryProfile.new profile_for(:will_paginate)
    $k.memory = MemoryProfile.new profile_for(:kaminari)
  end

  def profile_for(gem, scope=Dish.all, page=params[:page])
    MemoryProfiler.report(ignore_files: /memory_profiler/) do
      send(:"#{gem}_pagination", scope, page)
    end
  end

  def memory_chart_data
    data = [['', 'Memory', {role: 'annotation'}]]
    p,w,k = [$p,$w,$k].map{ |o| o.memory.size }
    data << ['Pagy',          p, ratio_annot(k, p, :less)]
    data << ['Will Paginate', w, ratio_annot(w, p, :more)]
    data << ['Kaminari',      k, ratio_annot(k, p, :more)]
  end

  def objects_chart_data
    data = [['Gems', 'Array', 'String', 'Hash', 'Others', {role: 'annotation'}]]
    data << ['Pagy',          *$p.memory.class_count]
    data << ['Will Paginate', *$w.memory.class_count]
    data << ['Kaminari',      *$k.memory.class_count]
    data.each_with_index do |l, i|
      next if i==0
      l[-1] ="#{number_with_delimiter(l[-1])} objects"
    end
  end

  def memory_pages_chart_data
    return $memory_pages_data unless Rails.env.production?

    p_start, w_start, k_start, p_end, w_end, k_end = nil

    $memory_pages_data = [['Pages',
                           'Pagy',          {role: 'annotation'}, {role: 'tooltip'},
                           'Will Paginate', {role: 'annotation'}, {role: 'tooltip'},
                           'Kaminari',      {role: 'annotation'}, {role: 'tooltip'} ]]

    (2..20).step(2).each do |n|
      scope = Dish.get_n_pages(n)
      page  = n/2
      p = MemoryProfile.new(profile_for(:pagy, scope, page), false).size
      w = MemoryProfile.new(profile_for(:will_paginate, scope, page), false).size
      k = MemoryProfile.new(profile_for(:kaminari, scope, page), false).size

      (p_start, w_start, k_start = p, w, k)  if n == 2
      if n == 20
        p_end, w_end, k_end = p, w, k
        pa = ratio p_end, p_start, :increase
        wa = ratio w_end, w_start, :increase
        ka = ratio k_end, k_start, :increase
      else
        pa, wa, ka = nil
      end

      p_tt = "Pagy: #{number_with_delimiter(p)} bytes for #{n} pages"
      w_tt = "Will Paginate: #{number_with_delimiter(w)} bytes for #{n} pages"
      k_tt = "Kaminari: #{number_with_delimiter(k)} bytes for #{n} pages"

      $memory_pages_data << [n, p, pa, p_tt, w, wa, w_tt, k, ka, k_tt]
    end

    $memory_pages_data
  end

  def increase_times(gem)
    col_index = {p:2, w:5, k:8}[gem]
    $memory_pages_data.last[col_index]
  end



  ######### IPS

  def init_ips
    return unless Rails.env.production?

    rep   = nil
    $ips_stats = capture_stdout { rep = benchmark_ips }

    ips = -> (obj){(obj.iterations * 1_000_000 / obj.microseconds).round(2)}

    $p.ips = ips.call rep.entries.find{|e| e.label == 'pagy'}
    $w.ips = ips.call rep.entries.find{|e| e.label == 'will_paginate'}
    $k.ips = ips.call rep.entries.find{|e| e.label == 'kaminari'}
  end

  def benchmark_ips
    Benchmark.ips do |x|
      x.config(:stats => :bootstrap) # , :warmup => 5, :time => 10)
      x.confidence = 99

      x.report('pagy')          { pagy_pagination }
      x.report('will_paginate') { will_paginate_pagination }
      x.report('kaminari')      { kaminari_pagination }

      x.compare!
    end
  end

  def ips_chart_data
    data = [['', 'IPS', {role: 'annotation'}]]
    p,w,k =  $p.ips, $w.ips, $k.ips
    data << ['Pagy',          p, ratio_annot(p, k, :faster)]
    data << ['Will Paginate', w, ratio_annot(p, w, :slower)]
    data << ['Kaminari',      k, ratio_annot(p, k, :slower)]
  end

  def comparison_chart_data
    data = [['ID', 'IPS (speed)', 'Lines Of Code', 'Complexity (objects)', 'Memory Size']]
    line = -> (label, obj){ [label, obj.ips, obj.code_size.loc_count, obj.memory.objects, obj.memory.size]}
    data << line.call('Pagy',          $p)
    data << line.call('Will Paginate', $w)
    data << line.call('Kaminari',      $k)
    # the bubble googleChart appears to have a bug: the smallest bubble (i.e. the bubble with the minimum
    # value of column 4) get drawn with a super small fixed size, regardless its relative size with
    # the other bubbles. It also doesn't get any label on it. As a work around, we draw a bubble
    # with all 0 values that position itself at the origin, so doesn't disturb the view of the chart.
    # That small bubble get the bug, and the other bubbles get drawn correctly.
    data << ['Origin', 0, 0, 0, 0]
  end



  ######### Pagy Init

  def init_pagy
    return unless Rails.env.production?

    $pagy.nav_ips     = nav_stats :ips_stats
    $pagy.nav_memory  = nav_stats :memory_stats
    $pagy.link_ips    = link_stats :ips_stats
    $pagy.link_memory = link_stats :memory_stats
    $pagy.i18n_ips    = i18n_stats :ips_stats
    $pagy.i18n_memory = i18n_stats :memory_stats
  end

  ######### Herlper vs Templates

  def pagy_helper_block
    # pagy = Pagy.new(count:1000, page: 20)
    pagy, records = pagy(Dish.all, page: 20)
    pagy_nav_bootstrap(pagy)
    pagy_info(pagy)
  end

  BOOTSTRAP_TEMPLATE = Pagy.root.join('templates', 'nav_bootstrap.html.slim').to_s
  # same as pagy_pagination done with template so we can compare the IPS with other gems
  # The block run with the template is only ~30% slower than the helper, so it is still ~17x faster than Kaminari
  def pagy_template_block
    # pagy = Pagy.new(count:1000, page: 20)
    pagy, records = pagy(Dish.all, page: 20)
    render file: BOOTSTRAP_TEMPLATE, locals: { pagy: pagy }
    pagy_info(pagy)
  end

  def nav_stats(meth)
    send meth, label1: '     pagy_nav', method1: [:pagy_helper_block],
               label2: 'pagy-template', method2: [:pagy_template_block]
  end


  ######### Link


  def pagy_link_block
    pagy = Pagy.new count: 1000, page: 20
    link = pagy_link_proc(pagy)
    20.times do |n|
      link.call n, n, 'data-remote=true'
    end
  end

  def rails_link_to_block
    20.times do |n|
      link_to n, url_for(page: n), remote: true
    end
  end

  def link_stats(meth)
    send meth, label1: 'pagy_link_proc', method1: [:pagy_link_block],
               label2: ' rails-link_to', method2: [:rails_link_to_block]
  end


  ######### I18n

  def i18n_block(meth)
    send meth, "pagy.info.multiple_pages", item_name: 'Dishes', count: 300, from: 101, to: 125
  end

  def i18n_stats(meth)
    send meth, label1: '       pagy_t', method1: [:i18n_block, :pagy_t],
               label2: '      rails-t', method2: [:i18n_block, :t]
  end



  ######### Utils


  def ips_stats(args)
    capture_stdout do
      Benchmark.ips do |x|
        x.config(:stats => :bootstrap) # , :warmup => 5, :time => 10)
        x.confidence = 99

        x.report(args[:label1]) { send *args[:method1] }
        x.report(args[:label2]) { send *args[:method2] }

        x.compare!
      end
    end
  end

  def memory_stats(args)
    # warmup
    send *args[:method1]
    send *args[:method2]

    p1 = MemoryProfiler.report(ignore_files: /memory_profiler/) { send *args[:method1] }
    p2 = MemoryProfiler.report(ignore_files: /memory_profiler/) { send *args[:method2] }

    p1, p2 = MemoryProfile.new(p1), MemoryProfile.new(p2)
    <<~EOS
      Memory -----------------------------------   
            #{args[:label1]}   #{'%7s' % number_with_precision(p1.size/1_024.0, precision: 2, delimiter: ',')} Kb
            #{args[:label2]}   #{'%7s' % number_with_precision(p2.size/1_024.0, precision: 2, delimiter: ',')} Kb - #{ratio(p2.size,p1.size,:more)}

      Objects -----------------------------------   
            #{args[:label1]}   #{'%7s' % number_with_delimiter(p1.objects)}
            #{args[:label2]}   #{'%7s' % number_with_delimiter(p2.objects)}    - #{ratio(p2.objects,p1.objects,:more)}

    EOS
  end



  ######### Helpers

  def ratio(a,b,q)
    r = (a/b.to_f)
    p = (r - r.round).abs < 0.1 ? 0 : 2
    "#{r.round(p)}x #{q}"
  end

  def ratio_annot(a,b,q)
    "#{(a/b.to_f).round}x #{q}"
  end

  def ratio_score(a,b,q)
    vala, valb = yield(a), yield(b)
    "~<b>#{(vala/valb.to_f).round}</b>x #{q}".html_safe
  end

  def ratio_ipskb_score(a,b,q)
    "~<b>#{(ips_per_kb(a)/ips_per_kb(b).to_f).round}</b>x #{q}".html_safe
  end

  def ips_per_kb(gem)
    (gem.ips / (gem.memory.size / 1_024.0)).round(2)
  end


end
