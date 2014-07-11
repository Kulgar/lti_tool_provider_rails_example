# Used to follow online course: https://canvas.instructure.com/courses/785215
require 'net/http'
require 'net/https'
class LtiCoursesController < ApplicationController
  
  # Given during the course exercices
  OAUTH_CONSUMER_SECRET = "2a43c95d793bf0b87ca58e27aceb6c45"
  
  skip_before_filter  :verify_authenticity_token
  
  #== LTI activity 1 tasks
  # Home could be used for LTI activity 1 module
  # Can also be used for LTI activity 6, section 1
  def home
    
  end

  #== LTI activity 2 tasks
  #=== Section 1
  #- Checking oauth_nonce - here we are storing it in an historic model
  def check_nonce
    @oauth_nonce = OauthNonce.create_or_update(params[:oauth_nonce].to_s)
  end
  
  #=== Section 2
  #- Checking oauth_timestamp
  def check_timestamp
    @oauth_date = Time.at(params[:oauth_timestamp].to_i).to_datetime unless params[:oauth_timestamp].blank?
    
    if @oauth_date && @oauth_date > (Time.now - 90.minutes).to_datetime
      @valid = true
    else
      @valid = false
    end
  end

  #=== Sections 3 & 4 
  #- We are using a library here to ease the signature validation
  def check_signature
    consumer_key = params[:oauth_consumer_key].to_s
    consumer_secret = OAUTH_CONSUMER_SECRET
    @provider = IMS::LTI::ToolProvider.new(consumer_key, consumer_secret, params)
  end

  #== LTI Activity 3
  #=== Sections 1 to 5
  #- Testing the redirection to launch_presentation_return_url
  def redirect_users
    uri = URI(params[:launch_presentation_return_url].to_s)
    uri.query ||= ""
    case params[:with_msg]
    when "lti_msg"
      new_param = ["lti_msg", "Most things in here don't react well to bullets."]
    when "lti_log"
      new_param = ["lti_log", "One ping only."]
    when "err_msg"
      new_param = ["lti_errormsg", "Who's going to save you, Junior?!"]
    when "err_log"
      new_param = ["lti_errorlog", "The floor's on fire... see... *&* the chair."]
    else
      new_param = []
    end
    new_query_ar = URI.decode_www_form(uri.query) << new_param
    uri.query = URI.encode_www_form(new_query_ar)
    redirect_to uri.to_s
  end

  #== LTI Activity 4
  #=== Sections 1 to 8
  #- We simply display here an xml page generated from: https://lti-examples.heroku.com/build_xml.html
  def config_xml
    render layout: false
  end

  #== LTI Activity 5
  #=== Section 1
  def return_types
    if !params[:ext_content_return_types].blank?
      @allowed_types = params[:ext_content_return_types].split(",")
    elsif !params[:selection_directive].blank?
      case params[:selection_directive]
      when "embed_content"
        @allowed_types = "image,iframe,link,basic_lti,oembed".split(",")
      when "select_link"
        @allowed_types = ["basic_lti"]
      when "submit_homework"
        @allowed_types = "link,file".split(",")
      else
        @allowed_types = ["none"]
      end
    else
      @allowed_types = ["none"]
    end
  end
  
  #=== Section 2 to 7
  def send_link_back
    uri = URI(params[:launch_presentation_return_url].to_s)
    uri.query ||= ""
    
    case params[:section]
    when "3"
      new_params = [["embed_type", "image"], ["url", "http://www.bacon.com/bacon.png"], ["alt", "bacon"], ["width", "200"], ["height", "100"]]
    when "4"
      new_params = [["embed_type", "iframe"], ["url", "http://www.bacon.com"], ["width", "200"], ["height", "100"]]
    when "5"
      new_params = [["embed_type", "file"], ["url", "http://www.bacon.com/bacon.docx"], ["text", "bacon.docx"], ["content_type", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]]
    when "6"
      new_params = [["embed_type", "basic_lti"], ["url", "http://www.bacon.com/bacon_launch"]]
    when "7"
      new_params = [["embed_type", "oembed"], ["url", "http://www.flickr.com/photos/bees/2341623661/"], ["endpoint", "http://www.flickr.com/services/oembed/"]]
    else
      new_params = [["embed_type", "link"], ["url", "http://www.bacon.com"], ["text", "bacon"]]
    end
    
    new_query_ar = URI.decode_www_form(uri.query)
    new_params.each do |new_param|
       new_query_ar << new_param
    end
    uri.query = URI.encode_www_form(new_query_ar)
    redirect_to uri.to_s
  end
  
  #== LTI Activity 6
  #=== Section 2
  #- We are using a library here to ease the grading functionnality
  def send_grade
    consumer_key = params[:oauth_consumer_key].to_s
    consumer_secret = OAUTH_CONSUMER_SECRET
    @provider = IMS::LTI::ToolProvider.new(consumer_key, consumer_secret, params)
    @cant_grade = false
    if @provider.valid_request?(request)
      grade = case params[:section]
      when "3"
        1.0
      when "4"
        0.43
      else
        0.9
      end
      @response = @provider.post_replace_result!(grade)
    else
      @cant_grade = true
    end
  end
  
  private
  
    def content_type_allowed?(content_type)
      if !params[:ext_content_return_types].blank?
        @allowed_types = params[:ext_content_return_types].split(",")
      elsif !params[:selection_directive].blank?
        case params[:selection_directive]
        when "embed_content"
          @allowed_types = "image,iframe,link,basic_lti,oembed".split(",")
        when "select_link"
          @allowed_types = ["basic_lti"]
        when "submit_homework"
          @allowed_types = "link,file".split(",")
        else
          @allowed_types = ["none"]
        end
      else
        @allowed_types = ["none"]
      end
      @allowed_types.include?(content_type.to_s)
    end
  
end