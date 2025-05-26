# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImageProcessingService do
  let(:file) { fixture_file_upload('spec/fixtures/files/test.jpg', 'image/jpeg') }
  let(:record) { create(:product) }
  let(:attachment_name) { :picture }

  describe '#call' do
    subject(:service_call) { described_class.new(file:, record:, attachment_name:).call }

    it 'processes and attaches the image' do
      expect { service_call }.to change { record.picture.attached? }.from(false).to(true)
    end

    it 'converts the image to webp format' do
      service_call
      expect(record.picture.content_type).to eq('image/webp')
    end

    it 'resizes the image to fit within the default dimensions' do
      service_call
      record.picture.open do |tempfile|
        image = Vips::Image.new_from_file(tempfile.path)
        expect(image.width).to be <= 1200
        expect(image.height).to be <= 675
      end
    end

    context 'when processing a wine image' do
      subject(:service_call) do
        described_class.new(file:, record:, attachment_name:, wine: true).call
      end

      it 'applies wine-specific processing' do
        service_call
        record.picture.open do |tempfile|
          image = Vips::Image.new_from_file(tempfile.path)
          expect(image.width).to eq(1200)
          expect(image.height).to eq(575)
        end
      end
    end

    context 'with a PNG image with transparency' do
      let(:file) { fixture_file_upload('test_no_bg.png', 'image/png') }

      it 'processes the image and removes transparency' do
        service_call
        expect(record.picture.content_type).to eq('image/webp')
        record.picture.open do |tempfile|
          image = Vips::Image.new_from_file(tempfile.path)
          expect(image.bands).to eq(3)
          expect(image.has_alpha?).to be false
        end
      end
    end

    context 'with custom dimensions' do
      subject(:service_call) do
        described_class.new(file:, record:, attachment_name:, size_x: 800, size_y: 600).call
      end

      it 'resizes the image to fit within the specified dimensions' do
        service_call
        record.picture.open do |tempfile|
          image = Vips::Image.new_from_file(tempfile.path)
          expect(image.width).to be <= 800
          expect(image.height).to be <= 600
        end
      end
    end
  end
end
