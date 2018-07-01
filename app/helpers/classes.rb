module CaptureSdout

  def capture_stdout
    old_stdout = $stdout
    $stdout    = StringIO.new

    yield

  rescue => e
    puts "Got an exception: #{e}", e.backtrace

  ensure
    out     = $stdout.string
    $stdout = old_stdout
    return out
  end

end


class CodeSize

  attr_reader  :files

  def initialize(files: [])

    @files = files.map do |filename|
               # name = filename.split(%r!/lib/!)[1]
               file = { name: filename, loc: 0 }
               in_comment = false
               File.new(filename).each_line do |l|
                 line = l.strip
                 if filename.end_with?('.erb')
                   in_comment = true if line.start_with?('<%#')
                   if line.start_with?('-%>')
                     in_comment = false
                     next
                   end
                   next if in_comment
                 else
                   next if line[0] == '#'
                 end
                 next if line.empty?
                 file[:loc] += 1
               end
               file
             end
  end

  # it works only for max 2 duplicates per filename
  def uniq_name_files
    new_files = []
    @files.each do |f|
      n = f
      n[:name] += ' ' if new_files.count{|e| e[:name] == n[:name]} > 0
      new_files << n
    end
    new_files
  end

  def loc_count
    @files.map{|f| f[:loc]}.sum
  end

  def file_count
    @files.size
  end

  def stats
    details = @files.sort { |a, b| b[:loc] <=> a[:loc] }.map do |f|
                "#{'%4d' % f[:loc]}  #{f[:name]}"
              end
    <<~EOS
      Code Size
      -----------------------------------
      #{ '%4d' % file_count}  Files
      #{ '%4d' % loc_count}  LOC
      -----------------------------------
      #{details.join("\n")}
    EOS
  end

end


class CodeStruct

  attr_reader :modules

  def initialize(mod, exclude=[])
    @modules = []   # {name: '', methods: [], is_class: bool }
    @exclude = exclude
    dig(mod)
  end

  def module_count
    @modules.size
  end

  def method_count
    @modules.map{|m| m[:methods].size }.sum
  end

  def class_count
    @modules.select{|m| m[:is_class] }.size
  end

  def stats
    details = @modules.sort { |a, b| b[:methods].size <=> a[:methods].size }.map do |mod|
                lines = "#{'%4d' % mod[:methods].size}  #{mod[:name]}\n"
                mod[:methods].each { |meth| lines << "        :#{meth}\n" }
                lines
              end
    <<~EOS
      Code Sructure
      -----------------------------------
      #{ '%4d' % module_count}  Modules (#{class_count} #{"Class".pluralize(class_count)})
      #{ '%4d' % method_count}  Methods
      -----------------------------------
      #{details.join("\n")}
    EOS
  end



  private

  def dig(mod)
    obj = {name: mod.name, methods: [], is_class: mod.is_a?(Class)}
    mod_methods = mod.methods(false) + mod.instance_methods(false) + mod.private_instance_methods(false)
    mod_methods.each do |m|
      obj[:methods].push(m) unless @exclude.any?{|r| m =~ r}
    end
    obj[:methods].sort!
    @modules << obj

    modules = mod.constants.map { |c| mod.const_get(c) }
                           .select { |c| c.is_a?(Module) &&
                                         !c.ancestors.include?(StandardError)  &&
                                         !c.name.start_with?('Rails') }
    modules.each do |m|
      next if @modules.find{|i| i[:name] == m.name}
      next if m == BasicObject
      dig(m)
    end
  end

end

class MemoryProfile
  include CaptureSdout

  attr_reader :stats, :size, :objects, :class_count

  def initialize(profile, enable_stats=true)
    @stats   = capture_stdout{ profile.pretty_print } if enable_stats
    @size    = profile.total_allocated_memsize
    @objects = profile.total_allocated
    @class_count = begin
                    obj     = profile.allocated_objects_by_class
                    arrays  = (obj.find{|i| i[:data] == 'Array'}||{})[:count] || 0
                    strings = (obj.find{|i| i[:data] == 'String'}||{})[:count] || 0
                    hashes  = (obj.find{|i| i[:data] == 'Hash'}||{})[:count] || 0
                    others  = obj.map{|i| i[:data] =~ /Array|String|Hash/ ? 0 : i[:count]}.sum
                    total   = obj.map{|i| i[:count]}.sum
                    [arrays, strings, hashes, others, total]
                  end
  end

end
