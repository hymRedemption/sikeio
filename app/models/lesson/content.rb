class Lesson::Content

  ASSETS_TAG = ["img", "video"]
  ASSET_BASE = "/courses/"

  attr_reader :course_name, :version, :lesson_name, :course

  def initialize(course, lesson)
    @course_name = course.name
    @lesson_name = lesson.name
    @course = course
    @version = course.current_version
  end

  def html_page(lang=nil)
    html_content = ""
    xml = xml_content(lang)
    xml.children.each do |node|
      if node.name != "exercise"
          html_content << node.to_xhtml
      else
        html_content << exercise_html(node)
      end
    end
    set_assets_src(html_content)
  end

  # does it have cn translation?
  def has_cn?
    !cn_xml_content.nil?
  end

  private

  def set_assets_src(content)
    xml = Nokogiri::HTML(content)
    ASSETS_TAG.each do |tag|
      xml.css(tag).each do |node|
        if !node["src"] =~ /^(http).*/
          node["src"] = asset_src(node["src"])
        end
      end
    end
    xml.css("body").children.to_xhtml
  end

  def asset_src(src)
    ASSET_BASE + course_name + "/" + lesson_name + "/" + src
  end

  def exercise_html(exercise_node)
    ol_content = ""
    first_step = true
    ol_tag_end = false
    exercise_node.css("step").each do |node|
      ol_content << exercise_step_html(node)
    end
    output =  <<-THERE
    <div class="exercise">
      #{exercise_title(exercise_node)}
      <ol class='exercise__steps'>
        #{ol_content}
      </ol>

      <div class="checkin checkin--uncompleted">
        <i class="fa fa-check-circle"></i>
      </div>
    </div>
    THERE
  end

  def exercise_step_html(exercise_step_node)
    li_content = ""

    exercise_step_node.children.each do |node|
      if node.name != "screenshot"
        li_content << node.to_xhtml
      elsif node.name == "video"
          li_content << video_html(node)
      else
        li_content << screenshot_html(node)
      end
    end

    output = <<-THERE
      <li class="exercise__steps__step">
        #{li_content}
      </li>
    THERE
  end

  def screenshot_html(screen_node)
    other_content = ""
    screen_node.children.each do |node|
      if node.name == "caption"
        other_content << "<h2>#{node.text}</h2>"
      elsif node.name == "video"
        other_content << video_html(node)
      else
        other_content << node.to_xhtml
      end
    end

    output = <<-THERE
      <div class="exercise__steps__step__screenshot">
        <img src=#{screen_node["src"]}/>
        #{other_content}
      </div>
    THERE
  end

  def exercise_title(exercise_node)
    h1_text = exercise_node.css("h1")[0].text
    output = <<-THERE
    <h1>
      #{h1_text}
      <div class="indicator">
        <i class="fa fa-wrench"></i>
        Exercise
      </div>
    </h1>
    THERE
  end

  def xml_content(lang=nil)
    if lang == "cn"
      cn_xml_content
    else
      course.content.page_dom(lesson_name)
    end

  end

  def cn_xml_content
    course.content.cnpage_dom(lesson_name)
  end
end
