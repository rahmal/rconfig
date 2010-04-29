class Object

  ##
  #   @person ? @person.name : nil
  #            - or -
  #  @people[:email] if @people
  #            - vs -
  #   @person.try(:name)
  def try(method, * args)
    result = send(method, * args) if respond_to?(method)
    result = send(:[], method) if result.nil? && respond_to?(:[])
    result
  end

  ##
  # Convience method for short-hand access to class specific config. If
  # a config specific to this class doesn't exist, it'll return the
  # root config instance.
  #
  # Example:
  #
  #   # Given CONFIG_PATH/person.yml (with param sort_by_lastname: true)
  #   @person = Person.new
  #   @person.config => $config.person
  #   @person.config.sort_by_lastname => true
  #
  #   # Given CONFIG_PATH/bank_account.yml  (with param mask_account_number: true)
  #   bank_acct = BankAccount.new
  #   bank_acct.config => $config.bank_account
  #   bank_acct.config.mask_account_number => true
  #
  #   # Given no specific config
  #   @person = Person.new
  #   @person.config => $config
  #   @person.config.bank_account => $config.bank_account
  #
  # NOTE: If there is a class-specific config file, and an object needs to
  #       access a different config, use the global instance ($config) or
  #       the class (RConfig).
  #
  def config
    this_config = $config.send(self.class.name.underscore.to_sym)
    this_config.blank? ? $config : this_config
  end

end
