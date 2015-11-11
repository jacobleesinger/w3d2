
class QuestionFollow

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    results.map {|result| QuestionFollow.new(result)}
  end

  def self.find_by_id(given_id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_follows WHERE id = #{given_id}")
    results.map {|result| QuestionFollow.new(result)}
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id, @user_id, @question_id =
    options.values_at('id', 'user_id', 'question_id')
  end

  def self.followers_for_question_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      JOIN
        questions ON  question_follows.question_id = questions.id
      WHERE
        questions.id = '#{given_id}'

    SQL
    results.map {|result| User.new(result)}
  end

  def self.followed_questions_for_user_id(given_id)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        users.id = '#{given_id}'

    SQL
    results.map {|result| Question.new(result)}
  end

  def self.most_followed_questions(num_of_questions_to_return)
    results = QuestionsDatabase.instance.execute(<<-SQL, num_of_questions_to_return)
    SELECT
      *
    FROM
      question_follows
    JOIN
      questions ON questions.id = question_follows.question_id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(question_follows.question_id) DESC
    LIMIT
      ?
    SQL
      results.map {|result| Question.new(result)}
  end

end
