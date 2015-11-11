
class Reply

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map {|result| Reply.new(result)}
  end

  def self.find_by_id(given_id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM replies WHERE id = #{given_id}")
    results.map {|result| Reply.new(result)}
  end

  def self.find_by_user_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = #{given_id}
    SQL
    results.map {|result| Reply.new(result)}
  end

  def self.find_by_question_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = #{given_id}
    SQL
    results.map {|result| Reply.new(result)}
  end


  attr_accessor :id, :body, :question_id, :parent_reply_id, :author_id

  def initialize(options)
    @id, @body, @question_id, @parent_reply_id, @author_id =
    options.values_at('id', 'body', 'question_id','parent_reply_id', 'author_id' )
  end

  def author
    User.find_by_id(author_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(parent_reply_id)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = '#{id}'

      SQL
    results.map {|result| Reply.new(result)}
  end

end
