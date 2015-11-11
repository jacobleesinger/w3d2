
class QuestionLike
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    results.map {|result| QuestionLike.new(result)}
  end

  def self.find_by_id(given_id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_follows WHERE id = #{given_id}")
    results.map {|result| QuestionLike.new(result)}
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

  def self.likers_for_question_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, given_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
         questions.id = ?

    SQL
    results.map {|result| User.new(result)}

  end

  def self.num_likes_for_question_id(given_id)

    results = QuestionsDatabase.instance.get_first_value(<<-SQL, given_id)
    SELECT
      COUNT(question_likes.id)
    FROM
      question_likes
    JOIN
      questions ON questions.id = question_likes.question_id

    WHERE
      questions.id = ?
    GROUP BY
      questions.id
      SQL

  end

  def self.liked_questions_for_user_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, given_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      JOIN
        users ON question_likes.user_id = users.id
      WHERE
        users.id = ?

    SQL
    results.map {|result| Question.new(result)}
  end

  def self.most_liked_questions(n)

    results = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON questions.id = question_likes.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(question_likes.question_id) DESC
      LIMIT
        ?

      SQL
        results.map { |result| Question.new(result) }
  end
end
