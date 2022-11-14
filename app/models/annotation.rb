class Annotation
  attr_reader :text, :referenced_text, :token_ids

  def initialize(referenced_text:, text:, token_ids:)
    @referenced_text = referenced_text
    @text = text
    @token_ids = token_ids
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
