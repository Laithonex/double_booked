class Account < ActiveRecord::Base
  has_many :balances
  validate :no_direct_subclass

  class << self
    attr_accessor :owner_type
  end

  def self.owned_by(klass)
    @owner_type = klass.to_s.classify.constantize
    belongs_to :owner, :polymorphic => true
    validate :check_owner_type
  end

  def balance_at(date)
    balance = balances.where(:evaluated_at => date).first
    balance ||= Balance.new(:account => self, :evaluated_at => date)
  end

  def balance_before(date)
    balances.find :first, :conditions => ["evaluated_at < ?", date],
                          :order => "evaluated_at DESC"
  end

  def current_balance
    balance_at(Time.now)
  end

private
  def check_owner_type
    errors.add_to_base "owner must be an #{self.class.owner_type}" if
      self.class.owner_type and !(owner.is_a? self.class.owner_type)
  end

  def no_direct_subclass
    # FIXME -- refactor Account as a mixin instead of using STI
    # consider using abstract_class for DetailAccount & SummaryAccount
    msg = "Record must not be an Account or a direct subclass of it. " +
          "Subclass the DetailAccount or SummaryAccount class instead."
    direct_subclass = self.class.superclass == Account || self.class == Account
    errors.add :base, msg if direct_subclass
  end

end
