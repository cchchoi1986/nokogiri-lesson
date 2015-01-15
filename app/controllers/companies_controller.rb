class CompaniesController < ApplicationController
  def index
    @companies = Company.all
  end
  def show
    @company = Company.find(params[:id])
    # @annualincomes = Annualincome.where(company_id: params[:id])
  end
end
