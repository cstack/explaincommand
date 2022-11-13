class Annotation
  attr_reader :text, :referenced_text

  def initialize(referenced_text:, text:)
    @referenced_text = referenced_text
    @text = text
  end

  def ==(other)
    referenced_text == other.referenced_text &&
      text == other.text
  end

  def to_json(*a)
    {
      'referenced_text' => referenced_text,
      'text' => text
    }.to_json(*a)
  end
end
