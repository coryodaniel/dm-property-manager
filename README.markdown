DM PropertyManager is useful when you have similar models with identical properties/relationships 
between the two.

Whenever a model manages another model it also gets a few factory methods: 
 * new_*model_name* : creates an unsaved instance
 * create_*model_name* : creates a saved instance
 * create_*model_name*_and_destroy : creates a saved instance and destroy the object you are working with
 
The factory methods will populate the created instance with all the values of the property of the managing
instance.

Example: Rsvp.manage(:seat){...do_something...}
Rsvp.new.respond_to? :new_seat #=> true

# Simple Example #

    class Rsvp
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id, Serial

      manage(:seat) do
        belongs_to :room #some other model
  
        property :confirmation, String
        property :section, String
        property :number, String
      end
    end

    class Seat
      include DataMapper::Resource

      property :id, Serial
      property :arrived_at, DateTime
    end

    @rsvp = Rsvp.new
    @rsvp.confirmation = "209fa9bj9jaa"
    @rsvp.section = "Orchestra"
    @rsvp.number  = "10A"
    @rsvp.save

    @seat = @rsvp.new_seat(:arrived_at=>Time.now)
    @seat.section #=> "Orchestra"
    @seat.arrived_at = "Fri May 01 21:18:24 -0700 2009"

  

# Delegation #
Delegation is useful when you have similar models, and you'd like to declare the like properties/relationships
in one place and delegate the control of the 'managed models' to another model.
  
For the example we have a ticket system with three types of tickets (yeah its a stupid example):
 * Unsold Tickets
 * Sold Tickets
 * Stubs 

    class UnsoldTicket
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id,     Serial
  
      manage(:sold_tickets => :stub) do
        belongs_to :concert
        property :seat,     String
        property :section,  Enum[:pit, :dance_floor, :really_far_back]
        property :price,    Float
      end
    end

    class SoldTicket
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id,     Serial
    end

    class Stub
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id,     Serial
    end
    
    @unsold_ticket = UnsoldTicket.new
    @unsold_ticket.concert = Concert.get("Britney Spears, Live from your butthole")
    @unsold_ticket.seat     = "33A"
    @unsold_ticket.section  = :pit
    @unsold_ticket.price    = 1.30
    @unsold_ticket.save
    
    @unsold_ticket.new_sold_ticket #=> an unsaved new ticket with the same properties
    @unsold_ticket.create_sold_ticket #=> a saved ticket with the same properties
    @unsold_ticket.create_sold_ticket(:price=>2.50) #=> a saved ticket overriding the price
    @unsold_ticket.create_sold_ticket_and_destroy #=> a saved ticket and destroy the unsold one
    
    @sold_ticket = @unsold_ticket.create_sold_ticket_and_destroy(:price => 25.30)
    
    # the concert comes and goes...
    @stub = @sold_ticket.create_stub_and_destroy #=> destroyes the sold ticket and makes it a ticket stub.


# Auto Archiver #
PropertyManager can be used to manage properties between a model and some archived version of the model
  
    class User
      include DataMapper::Resource
      include DataMapper::PropertyManager

      property :id,     Serial  
  
      manage(:archived_user) do
        property :name,   String
        property :email,  String
        property :password,  String
        property :created_at, DateTime
      end
  
      def archive!
        @au = new_archived_user
        @au.deleted_at = Time.now
        @au.save
        self.destroy
    
        @au
      end
  
    end

    class ArchivedUser
      include DataMapper::Resource
  
      def self.default_repository_name
        :my_archive_repository
      end
      property :id, Serial
      property :deleted_at, DateTime
    end

    user = User.new
    user.name = "Cory Odaniel"
    user.email = "propmanager@coryodaniel.com"
    user.password = "secretz"
    user.save

    # Move the user to the archive_users repo
    user.archive!