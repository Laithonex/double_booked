class Balance < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account, :evaluated_at, :balance
  before_create :set_balance

  def balance
    read_attribute(:balance) || set_balance
  end

  def calculate_balance
    entries.inject(previous_balance) {|balance, entry| balance + entry.amount}
  end

  def previous
    account.balance_before(evaluated_at)
  end

  def previous_balance
    previous ? previous.balance : 0
  end

  def readonly?
    !new_record?
  end

private
  def entries
    account.entries.find(:all, :conditions => entry_conditions,
                                 :joins => :transaction)
  end

  def entry_conditions
    column = "transactions.created_at"
    if previous
     ["#{column} > ? AND #{column} <= ?", previous.evaluated_at, evaluated_at]
    else
     ["#{column} <= ?", evaluated_at]
    end
  end

  def set_balance
    self.balance = calculate_balance
  end

end
