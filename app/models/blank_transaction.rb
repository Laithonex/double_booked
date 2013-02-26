class BlankTransaction
  attr_accessor :amount, :account_from, :account_to

  def initialize(amount, account_from)
    @amount = amount
    @account_from = account_from
  end

  def to(account_to, args = {})
    defaults = {
      :account_from => @account_from,
      :account_to => account_to,
      :amount => @amount
    }
    Transaction.create args.merge(defaults) 
  end
end
