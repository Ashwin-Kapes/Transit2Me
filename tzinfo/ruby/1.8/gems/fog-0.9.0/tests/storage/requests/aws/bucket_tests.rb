Shindo.tests('Fog::Storage[:aws] | bucket requests', [:aws]) do

  tests('success') do

    @bucket_format = {
      'CommonPrefixes'  => [],
      'IsTruncated'     => Fog::Boolean,
      'Marker'          => NilClass,
      'MaxKeys'         => Integer,
      'Name'            => String,
      'Prefix'          => NilClass,
      'Contents'    => [{
        'ETag'          => String,
        'Key'           => String,
        'LastModified'  => Time,
        'Owner' => {
          'DisplayName' => String,
          'ID'          => String
        },
        'Size' => Integer,
        'StorageClass' => String
      }]
    }

    @service_format = {
      'Buckets' => [{
        'CreationDate'  => Time,
        'Name'          => String,
      }],
      'Owner'   => {
        'DisplayName' => String,
        'ID'          => String
      }
    }

    tests("#put_bucket('fogbuckettests')").succeeds do
      Fog::Storage[:aws].put_bucket('fogbuckettests')
    end

    tests("#get_service").formats(@service_format) do
      Fog::Storage[:aws].get_service.body
    end

    file = Fog::Storage[:aws].directories.get('fogbuckettests').files.create(:body => 'y', :key => 'x')

    tests("#get_bucket('fogbuckettests)").formats(@bucket_format) do
      Fog::Storage[:aws].get_bucket('fogbuckettests').body
    end

    file.destroy

    tests("#get_bucket_location('fogbuckettests)").formats('LocationConstraint' => NilClass) do
      Fog::Storage[:aws].get_bucket_location('fogbuckettests').body
    end

    tests("#get_request_payment('fogbuckettests')").formats('Payer' => String) do
      Fog::Storage[:aws].get_request_payment('fogbuckettests').body
    end

    tests("#put_request_payment('fogbuckettests', 'Requester')").succeeds do
      Fog::Storage[:aws].put_request_payment('fogbuckettests', 'Requester')
    end

    tests("#put_bucket_website('fogbuckettests', 'index.html')").succeeds do
      pending if Fog.mocking?
      Fog::Storage[:aws].put_bucket_website('fogbuckettests', 'index.html')
    end

    tests("#delete_bucket_website('fogbuckettests')").succeeds do
      pending if Fog.mocking?
      Fog::Storage[:aws].delete_bucket_website('fogbuckettests')
    end

    tests("#delete_bucket('fogbuckettests')").succeeds do
      Fog::Storage[:aws].delete_bucket('fogbuckettests')
    end

  end

  tests('failure') do

    tests("#delete_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      Fog::Storage[:aws].delete_bucket('fognonbucket')
    end

    @bucket = Fog::Storage[:aws].directories.create(:key => 'fognonempty')
    @file = @bucket.files.create(:key => 'foo', :body => 'bar')

    tests("#delete_bucket('fognonempty')").raises(Excon::Errors::Conflict) do
      Fog::Storage[:aws].delete_bucket('fognonempty')
    end

    @file.destroy
    @bucket.destroy

    tests("#get_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      Fog::Storage[:aws].get_bucket('fognonbucket')
    end

    tests("#get_bucket_location('fognonbucket')").raises(Excon::Errors::NotFound) do
      Fog::Storage[:aws].get_bucket_location('fognonbucket')
    end

    tests("#get_request_payment('fognonbucket')").raises(Excon::Errors::NotFound) do
      Fog::Storage[:aws].get_request_payment('fognonbucket')
    end

    tests("#put_request_payment('fognonbucket', 'Requester')").raises(Excon::Errors::NotFound) do
      Fog::Storage[:aws].put_request_payment('fognonbucket', 'Requester')
    end

  end

end
