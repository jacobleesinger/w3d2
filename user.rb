
class User

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map {|result| User.new(result)}
  end

  def self.find_by_id(given_id)
    results = QuestionsDatabase.instance.execute("SELECT * FROM users WHERE id = #{given_id}")
    results.map {|result| User.new(result)}
  end

  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute (<<-SQL)
      SELECT
        *
      FROM
        users
      WHERE
        first_name = '#{fname}' AND last_name = '#{lname}'
    SQL
    results.map {|result| User.new(result)}
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  attr_accessor :id, :first_name, :last_name

  def initialize(options)
    @id, @first_name, @last_name =
    options.values_at('id', 'first_name', 'last_name')
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def save
    if id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, first_name, last_name)
      INSERT INTO
        users(first_name, last_name)
      VALUES
        (?,?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, first_name, last_name, id)
      UPDATE
        users
      SET
        first_name = ?,
        last_name = ?
      WHERE
        id = ?
      SQL

    end
  end
end
