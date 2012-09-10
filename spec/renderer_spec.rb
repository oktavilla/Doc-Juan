require_relative './spec_helper'
require_relative '../lib/doc_juan/renderer'

describe DocJuan do
  it "resolves a pdf renderer" do
    renderer = DocJuan.renderer "pdf"
    renderer.must_equal DocJuan::Pdf
  end

  it "resolves a jpg renderer" do
    renderer = DocJuan.renderer "jpg"
    renderer.must_equal DocJuan::Jpg
  end

  it "raises an error if we do not know the format" do
    proc {
      DocJuan.renderer "lulz"
    }.must_raise DocJuan::UnKnownFormat
  end
end
