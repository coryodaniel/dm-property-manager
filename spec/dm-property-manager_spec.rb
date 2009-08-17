######## START HELPER CLASSES
class TestManagee
  include DataMapper::Resource
  property :id, Serial
  property :something, String
  property :name, String
end
class TestManager
  include DataMapper::Resource
  include DataMapper::PropertyManager
  property :id, Serial
  property :fav_color, String
  property :name, String
  
  manage(:test_managee) do
    property :fav_number, Integer
    
    def to_s
      "#{name}'s favorite number is #{fav_number}"
    end
  end
end
class TDelegator
  include DataMapper::Resource      
  property :id, Serial
  property :something, String
end
class TDelegatee
  include DataMapper::Resource
  property :id, Serial
  property :something_else, String
end
class TDelegationManager
  include DataMapper::Resource
  include DataMapper::PropertyManager
  property :id, Serial
  property :name, String
  manage(:t_delegator => :t_delegatee) do
    property :other_property, String
  end
end

######## END HELPER CLASSES
describe DataMapper::PropertyManager do
  before(:all) do
    TestManager.auto_migrate!
    TestManagee.auto_migrate!
    TDelegator.auto_migrate!
    TDelegatee.auto_migrate!
    TDelegationManager.auto_migrate!
  end
  
  it 'should respond to manage' do
    TestManager.should respond_to(:manage)
  end
  
  it 'should respond to managed_properties' do
    TestManager.should respond_to(:managed_properties)
  end
  
  it 'should share properties between a manager and managee' do
    @tm = TestManager.new
    @te = TestManagee.new
    @tm.should respond_to(:fav_number)
    @te.should respond_to(:fav_number)
  end
  
  it 'should share methods between a manager and a managee' do
    @tm = TestManager.new
    @te = TestManagee.new
    @tm.name = "Test"
    @tm.fav_number = 3
    @tm.to_s.should == "Test's favorite number is 3"
    
    @te.name = "OtherTest"
    @te.fav_number = 9
    @te.to_s.should == "OtherTest's favorite number is 9"
  end
  
  it 'should be able to make a new managee' do
    @tm = TestManager.new
    @tm.fav_number =3
    @te = @tm.new_test_managee
    @te.fav_number.should be(3)
    
    @te = @tm.new_test_managee(:name => "Test",:fav_number => 5)
    @te.name.should == "Test"
    @te.fav_number.should be(5)
  end   
  
  it 'should be able to make a new managee w/ a provided block' do
    @tm = TestManager.new 

    @te = @tm.new_test_managee do |m|
      m.fav_number = 56
    end
    
    @te.fav_number.should be(56)
    
    @te = @tm.new_test_managee(:name => "Test") do |m|
      m.fav_number = 45
    end
    @te.name.should == "Test"
    @te.fav_number.should be(45)
  end
  
  it "should be able to create a new managee" do
    @tm = TestManager.new
    @tm.fav_number =3
    @te = @tm.create_test_managee
    @te.new_record?.should be(false)
  end
  
  it 'should be able to create a new managee w/ a provided block' do
    @tm = TestManager.new
    @tm.fav_number =3
    @te = @tm.create_test_managee do |m|
      m.name = "Managee"
    end
    @te.new_record?.should be(false)
    @te.name.should == "Managee"
  end
  
  it 'should be able to create a new managee and destroy the manager' do
    @tm = TestManager.new
    @tm.fav_number =3
    @te = @tm.create_test_managee
    @te.new_record?.should be(false)
    
    @tm.new_record?.should be(true)
  end
  
  it 'should be able to create a new managed and destroy the manager w/ a provided block' do
    @tm = TestManager.new
    @tm.fav_number =3
    @te = @tm.create_test_managee do |m|
      m.name = "testwee"
    end
    @te.new_record?.should be(false)
    @te.name.should == 'testwee'
    
    @tm.new_record?.should be(true)
  end
  
  it 'should be able to delegate property management to another model' do
    @dm = TDelegationManager.new
    @dm.should respond_to(:other_property)
    @dr = TDelegator.new
    @dr.should respond_to(:other_property)
    @de = TDelegatee.new
    @de.should respond_to(:other_property)
  end
  
  it 'should be able to delegate creation/destruction to another model' do
    TDelegationManager.new.should respond_to(:create_t_delegator)
    TDelegationManager.new.should_not respond_to(:create_t_delegatee)
    
    TDelegator.new.should respond_to(:create_t_delegatee)
  end
  
end