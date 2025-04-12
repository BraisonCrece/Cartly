# frozen_string_literal: true

class GeminiAiService < DryService
  include HTTParty

  def initialize(system_msg:, prompt:, image: nil, model: 'gemini-2.0-flash', temperature: 0.2)
    @system_msg = system_msg
    @prompt = prompt
    @image = image
    @model = model
    @temperature = temperature
    super()
  end

  def call
    response = self.class.post(api_url, request_options)

    return Failure(error: response) unless response.success?

    Success(extract_content(response))
  end

  private

  def api_url
    "https://generativelanguage.googleapis.com/v1beta/models/#{@model}:generateContent?key=#{ENV.fetch('GEMINI_KEY')}"
  end

  def request_options
    {
      headers: { 'Content-Type': 'application/json' },
      body: build_request_body.to_json,
    }
  end

  def build_request_body
    {
      contents: [{ parts: build_parts }],
      system_instruction: build_system_instruction,
      generationConfig: build_generation_config,
    }.compact
  end

  def build_parts
    parts = []
    parts << build_image_part if @image.present?
    parts << { text: @prompt }
    parts
  end

  def build_image_part
    {
      inline_data: {
        mime_type: 'image/webp',
        data: @image,
      },
    }
  end

  def build_system_instruction
    return unless @system_msg.present?

    { parts: [{ text: @system_msg }] }
  end

  def build_generation_config
    return unless @temperature.present?

    { temperature: @temperature }
  end

  def extract_content(response)
    response.dig('candidates', 0, 'content', 'parts', 0, 'text')
  end
end
