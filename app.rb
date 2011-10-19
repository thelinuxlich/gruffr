#!/usr/bin/env ruby
# encoding: UTF-8
require 'sinatra'
require 'sinatra/json'
require 'gruff'

COLORS = ["#FF9900","#FF3300","#99CC00","#666600","#FFFF00","#CCFF33","#993333","#996600","#CC3366","#FF66CC","#FFCC99","#FF9933","#FFCCCC","#CC99CC","#99CC99","#006600","#3399FF",
"#99CCFF","#66FFCC","#0033FF","#3300CC","#3333CC","#666699","#FFCCFF","#006699"]

before do
  content_type 'image/png'
  @size = (params[:size] || 800).to_i
end

def prepare(chart)
  font_size = params[:title_font_size] || 12
  theme = params[:theme] || ""
  eval("chart.theme_#{theme}") if theme != ""
  chart.title_font_size = font_size.to_f
  if params[:title]
    chart.title = params[:title]
  else
    chart.hide_title = true
  end
  if params[:legend_font_size]
    chart.legend_font_size = params[:legend_font_size].to_f
  end
  if params[:marker_font_size]
    chart.marker_font_size = params[:marker_font_size].to_f
  end
  labels = {}
  if params[:label]
    params[:label].each_with_index do |label,i|
      labels[i] = label
    end
  end
  chart.labels = labels if labels.size > 0
  chart.minimum_value = params[:minimum_value].to_f if params[:minimum_value]
  chart.maximum_value = params[:maximum_value].to_f if params[:maximum_value]
  chart
end

def generate(chart)
  COLORS.shuffle.each {|c| chart.colors << c }
  params[:valor].each_with_index do |v,i|
    if v.kind_of?(Array)
      valor = v.split(",").map {|n| n.to_f}
    else
      valor = v.to_i
    end
    chart.data(params[:legenda][i],valor)
  end
  chart.to_blob
end

get '/dot' do
  generate(prepare(Gruff::Dot.new(@size)))
end

get '/net' do
  generate(prepare(Gruff::Net.new(@size)))
end

get '/bar' do
  generate(prepare(Gruff::Bar.new(@size)))
end

get '/stackedbar' do
  generate(prepare(Gruff::StackedBar.new(@size)))
end

get '/sidebar' do
  generate(prepare(Gruff::SideBar.new(@size)))
end

get '/sidestackedbar' do
  generate(prepare(Gruff::SideStackedBar.new(@size)))
end

get '/pie' do
  generate(prepare(Gruff::Pie.new(@size)))
end

get '/line' do
  generate(prepare(Gruff::Line.new(@size)))
end

get '/area' do
  generate(prepare(Gruff::Area.new(@size)))
end

get '/stackedarea' do
  generate(prepare(Gruff::StackedArea.new(@size)))
end

get '/spider' do
  generate(prepare(Gruff::Spider.new(params[:max_value].to_f,@size)))
end
