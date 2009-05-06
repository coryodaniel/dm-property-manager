# A DataMapper module that allows one class to define properties in another, and 'spin off'
#   instances of that class

module DataMapper
  module PropertyManager
    def self.included(klass)
      klass.send :extend, ClassMethods
    end
  
    module ClassMethods
      # (managed_properties) - Properties being managed by this Model
      #
      # @author Cory Odaniel
      # @date Mon Apr 27 16:19:58 PDT 2009 
      #
      # @return Hash
      #
      def managed_properties
        @_managed_properties ||= {}
      end
    
      # (manage) - Define properties to manage on a model
      #
      # @author Cory Odaniel
      # @date Mon Apr 27 16:21:07 PDT 2009 
      #
      # @param klasses (~splat) list of model names to be managed
      # @params block  (&block) property declaration block to be eval'd onto classes
      #
      # @return NilClass
      # 
      # @example
      #    MyCoolModel.manage(:other_model) do
      #     property :fav_color, String
      #     property :fav_number, Integer
      #   end
      # 
      #   MyCoolModel.new.respond_to?(:fav_color) => true
      #   OtherModel.new.respond_to?(:fav_color) => true
      #   MyCoolModel.new.respond_to?(:fav_number) => true
      #   OtherModel.new.respond_to?(:fav_color) => true
      #   
      #   m = MyCoolModel.new
      #   m.fav_color = "black"
      #   om = m.new_other_model
      #   om.fav_color # => "black"
      #
      def manage(*klasses,&block)
        @delegated_klasses = klasses.pop if klasses.last.is_a?(Hash)
      
        # properties before eval
        original_properties = self.properties.inject([]){|memo,p| memo << p.name}
      
        self.class_eval &block
      
        current_properties = self.properties.inject([]){|memo,p| memo << p.name}
        new_properties = current_properties - original_properties

        klasses.each do |k|
          manage_klass(k,new_properties,&block)
        end #end klasses.each
      
        @delegated_klasses.each do |d,k|
          manage_klass(d,new_properties,&block)
          tmp_klass = Object.const_get(Extlib::Inflection.classify(d))
          tmp_klass.send(:include, DataMapper::PropertyManager)
          tmp_klass.manage_klass(k,new_properties,&block)
        end if @delegated_klasses
      
      end # end manage
    
      def manage_klass(k,props, &block)
        managed_properties[k.to_sym] ||= []
        managed_properties[k.to_sym]  += props
        managed_properties[k.to_sym].uniq!
              
        klass_name  = Extlib::Inflection.classify(k)
        klass       = Object.const_get klass_name
        klass.class_eval &block
      
        self.class_eval <<-MAKE_METHODS
          # Makes a managed whatnot, overrides with specified options
          def new_#{k}(opts={})
            self.class.managed_properties[:#{k}].each do |p|
              opts[p] ||= self.send(p)
            end
          
            return #{klass_name}.new(opts)
          end
          
          def create_#{k}(opts={})
            __new_managed_klass = new_#{k}(opts)
            __new_managed_klass.save
            __new_managed_klass
          end
          
          def create_#{k}_and_destroy(opts={})
            __new_managed_klass = create_#{k}(opts)
            self.destroy
            __new_managed_klass
          end
        MAKE_METHODS
      end
    end #end class_methods
  end #end Propertymanager
end