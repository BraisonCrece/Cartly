# frozen_string_literal: true

# rubocop:disable Metrics
class OpenAiService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def initialize
    @api_key = ENV.fetch('OPENAI_KEY') # Replace with your OpenAI API key
    @headers = {
      Authorization: "Bearer #{@api_key}",
      'Content-Type': 'application/json',
    }
  end

  def request(
    system_message:,
    prompt:,
    example_prompt: nil,
    example_response: nil,
    model: 'gpt-4o-mini',
    temperature: 0.7
  )
    body = {
      model: model,
      messages: [
        { role: 'developer', content: system_message },
        { role: 'user', content: prompt },
      ],
    }

    body[:temperature] = temperature unless model == 'o3-mini'

    response = self.class.post('/chat/completions', headers: @headers, body: body.to_json)

    Rails.logger.info { response.parsed_response['usage'] }

    return Response.new(error: response.message) unless response.success?

    Response.new(content: response['choices'][0]['message']['content'])
  end

  class Response
    attr_reader :content, :error

    def initialize(content: nil, error: nil)
      @content = content
      @error = error
    end

    def success?
      @content.present?
    end
  end
end
# rubocop:enable Metrics

# <HTTParty::Response:0x197c88 parsed_response={
#   "id"=>"chatcmpl-BJNHmwj4ktn2xEbQp9uNpZrgXUKjP",
#   "object"=>"chat.completion",
#   "created"=>1743957442,
#   "model"=>"gpt-4o-2024-08-06",
#   "choices"=>[
#     {
#       "index"=>0,
#       "message"=>{
#         "role"=>"assistant",
#         "content"=>"Vegan jackfruit tacos in cochinita style, served on corn tortillas with pickled red onion, fresh cilantro, and habanero chili sauce. Intense flavor and shredded texture that surprises the palate, 100% plant-based.",
#         "refusal"=>nil,
#         "annotations"=>[]
#       },
#       "logprobs"=>nil,
#       "finish_reason"=>"stop"
#     }],
#   "usage"=>{"prompt_tokens"=>127, "completion_tokens"=>49, "total_tokens"=>176, "prompt_tokens_details"=>{"cached_tokens"=>0, "audio_tokens"=>0}, "completion_tokens_details"=>{"reasoning_tokens"=>0, "audio_tokens"=>0, "accepted_prediction_tokens"=>0, "rejected_prediction_tokens"=>0}}, "service_tier"=>"default", "system_fingerprint"=>"fp_898ac29719"}, @response=#<Net::HTTPOK 200 OK readbody=true>, @headers={"date"=>["Sun, 06 Apr 2025 16:37:23 GMT"], "content-type"=>["application/json"], "transfer-encoding"=>["chunked"], "connection"=>["close"], "access-control-expose-headers"=>["X-Request-ID"], "openai-organization"=>["user-lomrdxiadnckowmw577mnhpt"], "openai-processing-ms"=>["850"], "openai-version"=>["2020-10-01"], "x-ratelimit-limit-requests"=>["500"], "x-ratelimit-limit-tokens"=>["30000"], "x-ratelimit-remaining-requests"=>["499"], "x-ratelimit-remaining-tokens"=>["29876"], "x-ratelimit-reset-requests"=>["120ms"], "x-ratelimit-reset-tokens"=>["248ms"], "x-request-id"=>["req_7cbcbb01e6b54002a8371f9a7047d5a6"], "strict-transport-security"=>["max-age=31536000; includeSubDomains; preload"], "cf-cache-status"=>["DYNAMIC"], "set-cookie"=>["__cf_bm=gAnoCaBAdUufzfo.pcuzcLgZ9juaCjtJfXB5JJytrfs-1743957443-1.0.1.1-A08sTRmeUbEv8oNMU3dLh4xR.W73IGBnwKn9fwA_4KfQiWImmcmvxA0cG303VvjBwoUAUXqBEsoDtzcuJM4ONbu6tv9WWwK9iLunYtqq7gc; path=/; expires=Sun, 06-Apr-25 17:07:23 GMT; domain=.api.openai.com; HttpOnly; Secure; SameSite=None", "_cfuvid=TRSUYPD4uzvGYiY7AujCSEzpaomM7U5XTpw1rhS0Hmc-1743957443753-0.0.1.1-604800000; path=/; domain=.api.openai.com; HttpOnly; Secure; SameSite=None"], "x-content-type-options"=>["nosniff"], "server"=>["cloudflare"], "cf-ray"=>["92c2b5a069fe0359-MAD"], "alt-svc"=>["h3=\":443\"; ma=86400"]}
