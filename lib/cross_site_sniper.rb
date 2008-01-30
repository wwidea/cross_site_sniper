module ActiveRecord #:nodoc:
  module AttributeMethods #:nodoc:
    # Cross Site Sniper (XSS)
    module ClassMethods
      
      # Piggybacks onto the end of ActiveRecord's define_attribute_methods
      # to wrap and automatically html_escape string and text fields.
      def define_attribute_methods_with_html_escaping
        
        # Let ActiveRecord define it's methods first.
        define_attribute_methods_without_html_escaping
        
        #Bail outta here if we're in an STI subclass situation.
        #Primary class will get the magic methods.
        return unless descends_from_active_record?
        
        content_columns.each do |column|
          #Only escape string and text fields
          next unless [:string,:text].include?(column.type)
          
          #Only escape fields that had their methods generated automatically.
          #so as not to interfere if the class defined it's own accessor method.
          next unless generated_methods.include?(column.name)
          
          define_method("#{column.name}_with_html_escaping") do
            
            # Retrieve the raw data.
            val = send("#{column.name}_without_html_escaping")
            
            # Only escape strings. Other data types, such
            # as 'nil', should be returned uncorrupted.
            val.is_a?(String) ? ERB::Util::h(val) : val
          end
          alias_method_chain column.name.to_sym, :html_escaping
          
          # Add newly generated methods to list just
          # in case we were called directly from
          # ActiveRecord::AttributeMethods::method_missing
          # and one of these is the missing method.
          generated_methods << "#{column.name}_with_html_escaping"
          generated_methods << "#{column.name}_without_html_escaping"
        end
        
      end
      alias_method_chain :define_attribute_methods, :html_escaping
    end
  end
end