# frozen_string_literal: true

# rubocop:disable Metrics/ParameterLists

# This class is responsible for processing
# and attaching an image to a record. It reduces the size of the image while maintaining
# default dimensions of the record and quality.
class ImageProcessingService
  attr_reader :file, :record, :attachment_name, :size_x, :size_y, :portrait, :background_fill

  def initialize(
    file:,
    record:,
    attachment_name:,
    portrait: false,
    background_fill: true,
    size_x: 1200,
    size_y: 675
  )
    @file = file
    @record = record
    @attachment_name = attachment_name
    @portrait = portrait
    @background_fill = background_fill
    @size_x = size_x
    @size_y = size_y
  end

  def call
    image = load_image
    processed_image = process_image(image)
    attach_processed_image(processed_image)
  end

  private

  def load_image
    image = Vips::Image.new_from_file(file.path, access: :sequential)
    image.bands == 4 && background_fill ? image.flatten(background: [255, 255, 255]) : image
  end

  def process_image(image)
    processor = ImageProcessing::Vips.source(image)
    processor = apply_portrait_processing(processor) if portrait
    processor
      .resize_to_fit(size_x, size_y)
      .convert('webp')
      .saver(Q: 75, strip: true)
      .call
  end

  def apply_portrait_processing(processor)
    adjusted_y = size_y - 100
    processor.resize_and_pad(size_x, adjusted_y, extend: :white)
  end

  def attach_processed_image(processed_image)
    record.public_send(attachment_name).attach(
      io: File.open(processed_image.path),
      filename: "p_#{file.original_filename}"
    )
  end
end
# rubocop:enable Metrics/ParameterLists
