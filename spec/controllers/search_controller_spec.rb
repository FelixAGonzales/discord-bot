require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe "GET #results" do
    let(:current_user) { FactoryBot.create(:user) }
    let(:search_params) { { q: "Test query" } }
    let(:authorized_response) { instance_double(HTTP::Response, body: "[{\"title\": \"Test result\", \"description\": \"Test description\"}]", status: 200) }
    let(:unauthorized_response) { instance_double(HTTP::Response, status: 401) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(HTTP).to receive(:get).and_return(authorized_response)
    end

    context "when the user is not signed in" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :results, params: search_params
      end

      it "redirects to the login page" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is signed in" do
      before do
        sign_in current_user
      end

      context "with valid query params" do
        it "returns a successful response" do
          get :results, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it "assigns @results with the parsed response body" do
          get :results, params: search_params
          expect(assigns(:results)).to eq([{"title" => "Test result", "description" => "Test description"}])
        end
      end

      context "with unauthorized response" do
        before do
          allow(HTTP).to receive(:get).and_return(unauthorized_response)
        end

        it "returns an unauthorized status" do
          get :results, params: search_params
          expect(response).to have_http_status(:unauthorized)
        end

        it "renders the unauthorized template" do
          get :results, params: search_params
          expect(response).to render_template(:unauthorized)
        end
      end
    end
  end
end