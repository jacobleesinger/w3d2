require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end


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
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed
    QuestionFollow.most_followed_questions(1)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end


end

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
end
