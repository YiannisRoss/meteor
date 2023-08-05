class WeatherDataController < ApplicationController
  before_action :authenticate

  # GET /weather_data
  def index
    if has_resume?
      if permitted_params[:latitude].present? && permitted_params[:longitude].present?
        weather_data = WeatherDataFetcher.call(permitted_params)
        render json: weather_data, status: :ok
      else
        render json: 'Latitude and longitude required', status: :bad_request
      end

    else
      render json: 'Resume upload required to view weather data', status: :unauthorized
    end
  end

  def create
    if has_resume?
      if permitted_params[:weather_data].present?

        data = StoredWeatherDataObject.new(user: Current.user, contents: permitted_params[:weather_data].to_json)

        if data.save
          render json: data, status: :ok
        else
          render json: 'Weather data save failed', status: :internal_server_error
        end

      else
        render json: 'Weather data required', status: :bad_request
      end

    else
      render json: 'Resume upload required to save weather data', status: :unauthorized
    end
  end

  private

  def permitted_params
    params.permit(:latitude, :longitude, weather_data: %i[time temperature])
  end

  def has_resume?
    Current.user.resume.attached?
  end
end
