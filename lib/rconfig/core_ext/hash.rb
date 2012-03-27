##
# source: http://rubyforge.org/projects/facets/
# version: 1.7.46
# license: Ruby License
# NOTE: remove this method if the Facets gem is installed.
# BUG: weave is destructive to values in the source hash that are arrays!
#      (this is acceptable for RConfig's use as the basis for weave!)
#
#
class Hash

  ##
  # Weaves the contents of two hashes producing a new hash.
  def weave(other_hash, clobber=false)
    return self unless other_hash
    unless other_hash.kind_of?(Hash)
      raise ArgumentError, "RConfig: (Hash#weave) expected <Hash>, but was <#{other_hash.class}>"
    end

    self_dup = self.dup # self.clone does not remove freeze!

    other_hash.each { |key, other_node|

      self_dup[key] =

          if self_node = self_dup[key]

            case self_node
              when Hash

                # hash1, hash2 => hash3 (recursive +)
                if other_node.is_a?(Hash)

                  self_node.weave(other_node, clobber)

                  # hash, array => error (Can't weave'em, must clobber.)
                elsif other_node.is_a?(Array) && !clobber

                  raise(ArgumentError, "RConfig: (Hash#weave) Can't weave Hash and Array")

                  # hash, array => hash[key] = array
                  # hash, value => hash[key] = value
                else
                  other_node
                end

              when Array

                # array, hash => array << hash
                # array1, array2 => array1 + array2
                # array, value => array << value
                unless clobber
                  case other_node
                    when Hash
                      self_node << other_node
                    when Array
                      self_node + other_node
                    else
                      self_node << other_node
                  end

                  # array, hash => hash
                  # array1, array2 => array2
                  # array, value => value
                else
                  other_node
                end

              else

                # value, array => array.unshift(value)
                if other_node.is_a?(Array) && !clobber
                  other_node.unshift(self_node)

                  # value1, value2 => value2
                else
                  other_node
                end

            end # case self_node

            # Target hash didn't have a node matching the key,
            # so just add it from the source hash.
            # !self_dup.has_key?(key) => self_dup.add(key, other_node)
          else
            other_node
          end

    } # other_hash.each

    self_dup # return new weaved hash
  end

  ##
  # Same as self.weave(other_hash, dont_clobber) except that it weaves other hash 
  # to itself, rather than create a new hash.
  def weave!(other_hash, clobber=false)
    weaved_hash = self.weave(other_hash, clobber)
    self.merge!(weaved_hash)
  end

end # class Hash

