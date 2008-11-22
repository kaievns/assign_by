# AssignBy
module ActiveRecord::AssignBy
  def self.included(base)
    base.instance_eval do
      
      def belongs_to(association_id, options={})
        assign_by = options[:assign_by]
        options.delete :assign_by
        
        super association_id, options
        
        if assign_by
          assign_by = [assign_by] unless assign_by.is_a?(Array)
          klass = Kernel.const_get(options[:class_name] || association_id.to_s.camelize)
          
          # overriding the original association method to clean our cache
          define_method "#{association_id}_with_assign_cache_clean=" do |value|
            send "#{association_id}_without_assign_cache_clean=", value
            
            assign_by.each do |field|
              instance_variable_set("@#{association_id}_#{field}", nil)
            end
          end
          alias_method_chain "#{association_id}=", :assign_cache_clean
          
          
          assign_by.each do |field|
            field_name = "#{association_id}_#{field}"
            
            # defining new virtual getter
            define_method field_name do
              if cached_name = instance_variable_get("@#{field_name}")
                cached_name
              elsif association = send(association_id)
                association.send field
              end
            end
            
            # defining new virtual setter
            define_method "#{field_name}=" do |value|
              send "#{association_id}=", klass.send("find_by_#{field}", value)
              instance_variable_set("@#{field_name}", value)
            end
            
            # defining validation methods for the virtual fields
            define_method "#{field_name}_validation_check" do
              value = instance_variable_get("@#{field_name}")
              unless value.blank?
                self.errors.add("#{field_name}", 'is not found') unless send(association_id)
              end
            end
            validate "#{field_name}_validation_check"
          end
          
          # saving the virtual methods map
          @@__assign_by_virtual_fields_map ||= {}
          @@__assign_by_virtual_fields_map[association_id.to_sym] = assign_by
        end
      end
      
      #
      # Checks if the associated model was assigned, by some defined field
      # or directly by a record
      #
      def self.validates_assign_of(*attr_names)
        return unless defined? @@__assign_by_virtual_fields_map
        
        options = attr_names.extract_options!

        attr_names.each do |association_id|
          fields = @@__assign_by_virtual_fields_map[association_id.to_sym]
          
          # checking the main association only if nothing of the virtual assignments was used
          module_eval <<-end_eval
            validates_presence_of association_id, options.merge(:if => proc{ |a| #{
              fields.collect{ |field|
                "a.#{association_id}_#{field}.nil?"
              }.join(' and ')
            }})
          end_eval
          
          # checking virtual assignments emptyness if they were used 
          fields.each do |field|
            module_eval <<-end_eval
              validates_presence_of "#{association_id}_#{field}", :if => proc{ |a|
                !a.#{association_id}_#{field}.nil?
              }
            end_eval
          end
        end
      end
    end
  end
end