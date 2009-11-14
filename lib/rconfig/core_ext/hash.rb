class Hash
  # source: http://rubyforge.org/projects/facets/
  # version: 1.7.46
  # license: Ruby License
  # NOTE: remove this method if the Facets gem is installed.
  # BUG: weave is destructive to values in the source hash that are arrays!
  #      (this is acceptable for our use as the basis for weave!)
  # -------------------------------------------------------------
  # Weaves two hashes producing a new hash. The two hashes need
  # to be compatible according to the following rules for each node:
  #
  #   <tt>
  #   hash, hash => hash (recursive +)
  #   hash, array => error
  #   hash, value => error
  #   array, hash => error
  #   array, array => array + array
  #   array, value => array << value
  #   value, hash => error
  #   value, array => array.unshift(valueB)
  #   valueA, valueB => valueB
  #   </tt>
  #
  # Example:
  #
  #   #TODO: Wite example.
  #
  def weave(h, dont_clobber=true)
    return self unless h
    raise ArgumentError, "Hash expected" unless h.kind_of?(Hash)
    s = self.dup # self.clone does not remove freeze!
    h.each { |k,node|
      node_is_hash = node.kind_of?(Hash)
      node_is_array = node.kind_of?(Array)
      if s.has_key?(k)
        self_node_is_hash = s[k].kind_of?(Hash)
        self_node_is_array = s[k].kind_of?(Array)
        if self_node_is_hash
          if node_is_hash
            s[k] = s[k].weave(node, dont_clobber)
          elsif node_is_array
            dont_clobber ? raise(ArgumentError, "{} <= [] is a tad meaningless") : s[k] = node
          else
            s[k] = node
          end
        elsif self_node_is_array
          if node_is_hash
            dont_clobber ? s[k] = s[k] << node : s[k] = node
          elsif node_is_array
            dont_clobber ? s[k] += node : s[k] = node
          else
            dont_clobber ? s[k] = s[k] << node : s[k] = node
          end
        else
          if node_is_hash
            s[k] = node
          elsif node_is_array
            dont_clobber ? s[k].unshift( node ) : s[k] = node
          else
            s[k] = node
          end
        end
      else
        s[k] = node
      end
    }
    s
  end
  def weave!(h, dont_clobber = true) self.merge! self.weave(h, dont_clobber) end
end
