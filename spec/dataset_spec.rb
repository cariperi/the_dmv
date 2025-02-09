require 'spec_helper'

RSpec.describe Dataset do
  before(:each) do
    @vehicle_factory = VehicleFactory.new
    @facility_factory = FacilityFactory.new

    @wa_ev_registrations = DmvDataService.new.wa_ev_registrations
    @oregon_facilities_data = DmvDataService.new.or_dmv_office_locations
    @new_york_facilities_data = DmvDataService.new.ny_dmv_office_locations
    @missouri_facilities_data = DmvDataService.new.mo_dmv_office_locations

    @wa_ev_vehicles = @vehicle_factory.create_vehicles(@wa_ev_registrations)
    @oregon_facilities = @facility_factory.create_facilities(@oregon_facilities_data, :OR)
    @new_york_facilities = @facility_factory.create_facilities(@new_york_facilities_data, :NY)
    @missouri_facilities = @facility_factory.create_facilities(@missouri_facilities_data, :MO)

    @wa_ev_dataset = Dataset.new(@wa_ev_vehicles)
    @oregon_dataset = Dataset.new(@oregon_facilities)
    @new_york_dataset = Dataset.new(@new_york_facilities)
    @missouri_dataset = Dataset.new(@missouri_facilities)
  end

  describe '#initialize' do
    it 'exists' do
      expect(@wa_ev_dataset).to be_a Dataset
      expect(@oregon_dataset).to be_a Dataset
      expect(@new_york_dataset).to be_a Dataset
      expect(@missouri_dataset).to be_a Dataset
    end

    it 'has data' do
      expect(@wa_ev_dataset.data).to eq(@wa_ev_vehicles)
      expect(@wa_ev_dataset.data).to be_a Array
      expect(@wa_ev_dataset.data.first).to be_a Vehicle

      expect(@oregon_dataset.data).to eq(@oregon_facilities)
      expect(@oregon_dataset.data).to be_a Array
      expect(@oregon_dataset.data.first).to be_a Facility

      expect(@new_york_dataset.data).to eq(@new_york_facilities)
      expect(@new_york_dataset.data).to be_a Array
      expect(@new_york_dataset.data.first).to be_a Facility

      expect(@missouri_dataset.data).to eq(@missouri_facilities)
      expect(@missouri_dataset.data).to be_a Array
      expect(@missouri_dataset.data.first).to be_a Facility
    end
  end

  describe '#most_popular_make_model' do
    it 'returns an array with vehicle make and model' do
      expect(@wa_ev_dataset.most_popular_make_model).to be_a Array
      expect(@wa_ev_dataset.most_popular_make_model).to_not be ([])
    end

    it 'includes both make and model attributes' do
      makes = @wa_ev_dataset.data.map { |vehicle| vehicle.make }
      models = @wa_ev_dataset.data.map { |vehicle| vehicle.model }
      expect(makes).to include(@wa_ev_dataset.most_popular_make_model[0])
      expect(models).to include(@wa_ev_dataset.most_popular_make_model[1])
    end
  end

  describe '#count_by_model_year' do
    it 'returns an integer count' do
      expect(@wa_ev_dataset.count_by_model_year(2019)).to be_a Integer
    end

    it 'returns the count of vehicles for a given year only' do
      model_years = @wa_ev_dataset.data.map { |vehicle| vehicle.year }
      expected = model_years.find_all { |year| year == "2019" }.count
      expect(@wa_ev_dataset.count_by_model_year(2019)).to eq(expected)
    end

    it 'allows for year argument to be an integer or a string' do
      with_string = @wa_ev_dataset.count_by_model_year("2019")
      with_integer = @wa_ev_dataset.count_by_model_year(2019)
      expect(with_string).to eq(with_integer)
    end
  end

  describe '#county_with_most_vehicles' do
    it 'returns a string' do
      expect(@wa_ev_dataset.county_with_most_vehicles).to be_a String
    end

    it 'returns a valid county as a value' do
      counties = @wa_ev_dataset.data.map { |vehicle| vehicle.county }
      expect(counties).to include(@wa_ev_dataset.county_with_most_vehicles)
    end
  end

  describe '#get_make' do
    it 'returns the most popular make as a string' do
      expect(@wa_ev_dataset.get_make(@wa_ev_dataset.data)).to be_a String
    end
  end

  describe '#get_model' do
    it 'returns the most popular model as a string' do
      make = @wa_ev_dataset.get_make(@wa_ev_dataset.data)

      expect(@wa_ev_dataset.get_model(@wa_ev_dataset.data, make)).to be_a String
    end
  end
end
