class CoursesController < ApplicationController

  layout "logined"

  before_action :require_login
#  before_action :require_course_exists,except:[:list,:create_enroll]
#  before_action :require_take_part_in,only:[:show]
  before_action :ensure_trailing_slash, only:[:show]

  def show
    @enrollment = current_user.enrollments.find_by(course: course)

    if !enrollment_valid?(@enrollment)
      redirect_to root_path(course: course.permalink)
      return
    end

    @enrollment.update!(last_visit_time: Time.now)
    @send_day = Time.now.beginning_of_day.to_f * 1000 # convert to milliseconds for js
    #render '_show'
  end

  private

  def course
    @course ||= Course.find_by!(permalink: params[:id])
  end


=begin
  def require_course_exists
    course = Course.find_by_id(params[:id]) || Course.find_by_id(params[:course_id])
    redirect_to root_path unless course
  end
=end

  def require_course_exists(course_id)
    course = Course.find course_id
    redirect_to root_path unless course
  end

  def update_record
    user = current_user
    course = Course.find params[:id]
    user.courses = course
  end


end
