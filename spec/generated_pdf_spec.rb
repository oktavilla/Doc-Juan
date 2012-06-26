require_relative './spec_helper'

require_relative '../lib/doc_juan/generated_pdf'

describe DocJuan::GeneratedPdf do
  let(:path) { '/documents/document.rb' }

  it 'is ok' do
    pdf = DocJuan::GeneratedPdf.new path, true
    pdf.ok?.must_equal true
  end

  it 'is not ok' do
    pdf = DocJuan::GeneratedPdf.new path, false
    pdf.ok?.must_equal false
  end
end
