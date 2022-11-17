class Annotation
  attr_reader :text, :referenced_text, :token_ids, :source_link, :source_description

  def initialize(referenced_text:, text:, token_ids:, source_link: nil, source_description: nil)
    @referenced_text = referenced_text
    @text = text
    @token_ids = token_ids
    @source_link = source_link
    @source_description = source_description
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
