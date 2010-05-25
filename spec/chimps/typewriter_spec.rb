require File.join(File.dirname(__FILE__), '../spec_helper')

describe Chimps::Typewriter do

  def dataset_1
    {
      'dataset'       => {
        'id'          => 39293,
        'cached_slug' => 'my-awesome-dataset',
        'updated_at'  => 'tomorrow',
        'title' => 'My Awesome Dataset'
      }
    }
  end

  def dataset_2
    {
      'dataset'       => {
        'id'          => 28998,
        'cached_slug' => 'my-other-awesome-dataset',
        'updated_at'  => 'yesterday',
        'title' => 'My Other Awesome Dataset'
      }
    }
  end

  def source
    {}                          # FIXME
  end

  def license
    {}                          # FIXME
  end

  def resource
    dataset_1
  end

  def resource_listing
    [ dataset_1, dataset_2 ]
  end

  def errors
    [
     "A title is required.",
     "A description is required."
    ]
  end

  def batch
    [
     {
       'status'      => 'created',
       'resource'    => resource,
       'errors'      => nil,
       'local_paths' => []
     },
     {
       'status' => 'invalid',
       'errors' => errors
     }
    ]
  end

  def search
    {
      'results' => [
                    { 'dataset' => dataset_1 },
                    { 'dataset' => dataset_2 }
                   ]
    }
    
  end

  def api_account
    {
      'api_key' => "tie5TeeNei2aigie",
      'owner'   => {
        'username' => 'Infochimps'
      },
      'updated_at' => 'now'
    }
  end
  
    

  before { @typewriter = Chimps::Typewriter.new([]) }

  describe "formatting output" do

    before do
      @typewriter.concat([["short", "medium", "very_very_very_long"],
                       ["medium", "very_very_long", "short"],
                       "Some totally long but also ignored string", # ignores strings
                       ["very_long", ""]]) # doesn't mind mixed size rows
    end

    it "should calculate its column widths before printing" do
      $stdout = File.open('/dev/null', 'w')
      @typewriter.print($stdout)
      @typewriter.column_widths.should_not be_empty
    end

    it "should correctly calculate its column widths" do
      @typewriter.send(:calculate_column_widths!)
      @typewriter.column_widths.should == ["very_long", "very_very_long", "very_very_very_long"].map(&:size)
    end

  end
  

  
end

