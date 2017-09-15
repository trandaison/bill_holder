class Ajax::PassCodesController < ApplicationController
  def verify
    @status = ENV['PASS_CODE'] == params[:pass_code] ? 200 : 400
  end
end
