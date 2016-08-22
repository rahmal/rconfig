##
# Copyright (c) 2009 Rahmal Conda <rahmal@gmail.com>
#
# Config is a special class, derived from HashWithIndifferentAccess.
# It was specifically created for handling config data or creating mock 
# objects from yaml files. It provides a dotted notation for accessing 
# embedded hash values, similar to the way one might traverse a object tree.
#
module RConfig
  class Config < ::HashWithIndifferentAccess

    ##
    # HashWithIndifferentAccess#default is broken in early versions of Rails.
    # This is defined to use the hash version in Config#default
    define_method(:hash_default, Hash.instance_method(:default))

    ##
    # Dotted notation can be used with arguments (useful for creating mock objects)
    # in the YAML file the method name is a key, argument(s) form a nested key,
    # so that the correct value is retrieved and returned.
    #
    # For example loading to variable foo a yaml file that looks like:
    # customer:
    #   id: 12345678
    #   verified:
    #     phone: verified
    #     :address: info_not_available
    #     ? [name, employer]
    #     : not_verified
    #
    # Allows the following calls:
    # foo.customer.id                 => 12345678
    # foo.customer.verified.phone     => verified
    # foo.customer.verified("phone")  => verified
    # foo.customer.verified(:address) => info_not_available
    # foo.customer.verified("name", "employer") => not_verified
    #
    # Note that :address is specified as a symbol, where phone is just a string.
    # Depending on what kind of parameter the method being mocked out is going
    # to be called with, define in the YAML file either a string or a symbol.
    # This also works inside the composite array keys.
    def method_missing(method, *args)
      method = method.to_s
      return if method == 'default_key'
      value = self[method]
      case args.size
      when 0  # e.g.: RConfig.application.method
        value
      when 1  # e.g.: RConfig.application.method(one_arg)
        value.send(args[0])
      else    # e.g.: RConfig.application.method(arg_one, args_two, ...)
        value[args]
      end
    end

    ##
    # Why the &*#^@*^&$ isn't HashWithIndifferentAccess doing this?
    # HashWithIndifferentAccess doesn't override Hash's []! That's 
    # why it's so destructive!
    def [](key)
      key = key.to_s if key.kind_of?(Symbol)
      super(key)
    end

    ##
    # Allow hash.default => hash['default']
    # without breaking Hash's usage of default(key)
    def default(key = self.default_key)
      key = key.to_s if key.is_a?(Symbol)
      if key == self.default_key 
        self['default'] if key?('default')
      else
        hash_default(key)
      end
    end

    protected

  end # class Config
end
