include ActionDispatch::TestProcess

FactoryGirl.define do

  factory :item do
    tags ['tag1', 'tag2']
    name 'some name'
    image fixture_file_upload('spec/fixture_files/zhirafchiks.gif')
  end

end
