require 'ostruct'

class ComparisonController < ApplicationController

  include Pagy::Backend

  before_action :init_gems_data, only: [:gems, :screenshots]
  # after action order inverted
  after_action :reset_gems_data, only: :gems2
  after_action  :save_gems_data, only: :gems2

  before_action :init_pagy_data, only: :pagy_action
  # after action order inverted
  after_action :reset_pagy_data, only: :pagy1
  after_action  :save_pagy_data, only: :pagy1

  helper_method :pagy      # we use #pagy also in the comparison helpers

  before_action :set_pagy_vars

  def gems
    @will_paginate_records = Dish.all.page(params[:page])
    @kaminari_records      = Dish.all.kaminari_page(params[:page])
  end


  def pagy_action
    render 'pagy'
  end

  def responsive_screencast
    @pagy, @records = pagy(Dish.all)
  end


  private

    def set_pagy_vars
      @pagy, @records = pagy(Dish.all)
    end

  GEMS_DATA_FILE = Rails.root.join('db', 'saved_gems_data')

  def init_gems_data
    if Rails.env.production?
      if helpers.fair_range?
        $p = OpenStruct.new
        $w = OpenStruct.new
        $k = OpenStruct.new
      else
        redirect_to gems_url(page: 20), notice: %(Page ##{params[:page]} is a page out of the range 12..28, which is the range fair for all gems (see the "Page Range" note below). Showing comparisons for page #20 instead.)
      end
    else
      load_gems_data
    end
  end

  def load_gems_data
    page = params[:page]
    params[:page], $p, $w, $k, $ips_stats, $memory_pages_data = Marshal.load GEMS_DATA_FILE.binread
    if params[:page] != page
      redirect_to gems_url(page: params[:page]), notice: %(In #{Rails.env.inspect} mode you cannot run comparisons for pages other than the last production-recorded page ##{params[:page]} (see the "Environment" note below). Please, restart the rails server in production mode if you want to run the comparisons for other pages.)
    end
  end

  def save_gems_data
    if Rails.env.production? && helpers.fair_range?
      GEMS_DATA_FILE.open('wb') do |f|
        f.write Marshal.dump( [params[:page], $p, $w, $k, $ips_stats, $memory_pages_data] )
      end
    end
  end

  def reset_gems_data
    $p, $w, $k, $ips_stats, $memory_pages_data = nil
  end



  PAGY_DATA_FILE = Rails.root.join('db', 'saved_pagy_data')

  def init_pagy_data
    if Rails.env.production?
      $pagy = OpenStruct.new
    else
      load_pagy_data
    end
  end

  def load_pagy_data
    $pagy = Marshal.load PAGY_DATA_FILE.binread
  end

  def save_pagy_data
    if Rails.env.production?
      PAGY_DATA_FILE.open('wb') do |f|
        f.write Marshal.dump( $pagy )
      end
    end
  end

  def reset_pagy_data
    $pagy = nil
  end

end
