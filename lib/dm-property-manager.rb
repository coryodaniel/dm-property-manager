# A DataMapper module that allows one class to define properties in another, and 'spin off'
#   instances of that class

# TODO, has relationships should auto populate

# TODO, belongs_to relationships should auto populate, currently you have to do this to get it
#   to work
# manage(:someclass) do
#   belongs_to :something
#   property :something_id, Integer
#
# end
#
module DataMapper
  module PropertyManager
    VERSION = '0.1.0'
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

      # 
      # I started to implement before/after hooks for managed model creation, but ended up not needing it.
      #   Does anyone need it?
      #
      # # accessor for before/after hooks hash
      # def manage_before_and_after_hooks
      #   @_manage_before_and_after_hooks ||= {}
      # end
      # # add a before hook manage_before(:create, :my_class) do...
      # def manage_before(action, klass, &block)
      #   self.managed_hooks_for(:before, action, klass).push(block)
      # end                                                        
      # # add an after hook manage_after(:new, :my_class) do...
      # def manage_after(action, klass, &block)
      #   self.managed_hooks_for(:after, action, klass).push(block)
      # end
      # #Creates key for hooks to keep hash shallow
      # def managed_hook_key(hook, action, klass)
      #   :"#{hook}_#{action}_#{klass}"
      # end                  
      # # hook storage access
      # def managed_hooks_for(hook, action, klass)            
      #   _hook_key = managed_hook_key hook, action, klass
      #   self.manage_before_and_after_hooks[_hook_key] ||= []
      # end
    
      def manage_klass(k,props, &block)
        managed_properties[k.to_sym] ||= []
        managed_properties[k.to_sym]  += props
        managed_properties[k.to_sym].uniq!

        klass_name  = Extlib::Inflection.classify(k)
        klass       = Object.const_get klass_name

        klass.class_eval &block
      
        self.class_eval <<-MAKE_METHODS
          # Makes a managed whatnot, overrides with specified options
          #
          # my_manager.new_managee(:name => "cool name") do |mngee|
          #   mngee.description = "the description set by block"
          # end
          # 
          # Parameters and block behavior are the same for new_*, create_*, and create_*_and_destroy
          #
          # Order in which properties are set
          # 1. Properties are inherited from managing class
          # 2. Any properties passed in 'opts' will override those in step #1
          # 3. Any properties set in a passed in block will override those in step #1 & 2
          # 
          def new_#{k}(opts={})
            self.class.managed_properties[:#{k}].each do |p|
              opts[p] ||= self.send(p)
            end

            __managed_instance = #{klass_name}.new(opts)
            
            yield(__managed_instance) if block_given?
            return __managed_instance
          end
          
          def create_#{k}(opts={})
            __new_managed_klass = new_#{k}(opts)
                        
            yield(__new_managed_klass) if block_given?
            __new_managed_klass.save           
            
            __new_managed_klass
          end
          
          def create_#{k}_and_destroy(opts={})
            __new_managed_klass = create_#{k}(opts)
            yield(__new_managed_klass) if block_given?
            self.destroy
            __new_managed_klass
          end
        MAKE_METHODS
      end
    end #end class_methods
  end #end Propertymanager
end