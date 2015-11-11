
class Question

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map {|result| Question.new(result)}
  end

  def self.find_by_id(given_id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE id = #{given_id}")
    results.map {|result| Question.new(result)}
  end

  def self.find_by_author_id(id)
    results = QuestionsDatabase.instance.execute (<<-SQL)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = #{id}
    SQL
    results.map {|result| Question.new(result)}
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options)
    @id, @title, @body, @author_id =
    options.values_at('id', 'title', 'body', 'author_id')
  end

  def author
    User.find_by_id(author_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end


end
