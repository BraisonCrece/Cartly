class ImageProcessingService
  attr_reader :file, :record, :attachment_name, :size_x, :size_y, :wine

  def initialize(file:, record:, attachment_name:, wine: false, size_x: 1200, size_y: 675)
    @file = file
    @record = record
    @attachment_name = attachment_name
    @wine = wine
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
    image.bands == 4 ? image.flatten(background: [255, 255, 255]) : image
  end

  def process_image(image)
    processor = ImageProcessing::Vips.source(image)
    processor = apply_wine_processing(processor) if wine
    processor
      .resize_to_fit(size_x, size_y)
      .convert('webp')
      .saver(Q: 75, strip: true)
      .call
  end

  def apply_wine_processing(processor)
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
