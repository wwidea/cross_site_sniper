module ActiveRecord #:nodoc:
  module AttributeMethods #:nodoc:
    # Cross Site Sniper (XSS)
    module ClassMethods
      
      # Piggybacks onto the end of ActiveRecord's define_attribute_methods
      # to wrap and automatically html_escape string and text fields.
      def define_attribute_methods_with_html_escaping
        
        # Let ActiveRecord define it's methods first.
        define_attribute_methods_without_html_escaping
        
        content_columns.each do |column|
          next unless [:string,:text].include?(column.type)
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