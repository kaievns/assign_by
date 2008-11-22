# AssignBy
module ActiveRecord::AssignBy
  def self.included(base)
    base.instance_eval do
      
      def belongs_to(association_id, options={})
        assign_by = options[:assign_by]
        options.delete :assign_by
        
        super association_id, options
        
        if assign_by
          klass = Kernel.const_get(options[:class_name] || association_id.to_s.camelize)
          
          (assign_by.is_a?(Array) ? assign_by : [assign_by]).each do |field|
            define_method "#{association_id}_#{field}" do
            end
            
            define_method "#{association_id}_#{field}=" do
            end
          end
        end
      end
    end
  end
end