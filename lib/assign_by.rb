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
            
            # defining new virtual getter
            define_method "#{association_id}_#{field}" do
              if cached_name = instance_variable_get("@#{association_id}_#{field}")
                cached_name
              elsif association = send(association_id)
                association.send field
              end
            end
            
            # defining new virtual setter
            define_method "#{association_id}_#{field}=" do |value|
              send "#{association_id}=", klass.send("find_by_#{field}", value)
              instance_variable_set("@#{association_id}_#{field}", value)
            end
          end
        end
      end
    end
  end
end