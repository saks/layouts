include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :item do
    tags ['tag1', 'tag2']
    name 'some name'
    image fixture_file_upload('spec/fixture_files/zhirafchiks.gif')
    suite_id nil
  end

  factory :suite do
    items []
  end

end
