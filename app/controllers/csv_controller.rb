class CsvController < ApplicationController
  # フラッシュメッセージを Bootstrap 対応させるための設定
  add_flash_types :success, :info, :warning, :danger
  
  def index; end

  def create
    model_name = params[:model_name]
    
    # results は JSON 形式の配列で渡ってくるので parse が必要
    results = params[:results].map { |row_json| JSON.parse(row_json) }

    instances = results.map do |attributes|
      model_name.constantize.new(attributes)
    end

    # バルクインサート
    model_name.constantize.import(instances)

    redirect_to csv_index_path, success: set_flash_message(model_name)
  end

  def import
    file = params[:file]
    @model_name = params[:model_name]

    # CsvImporter.run() の返り値は Hash 形式の配列
    @results, @errors = CsvImporter.run(file, @model_name)

    respond_to do |format|
      if @errors.present?
        format.js { render :error }
      else
        format.js { render :success }
      end
    end
  end

  private

    # モデルによって異なるフラッシュメッセージを設定
    def set_flash_message(model_name)
      "#{t("activerecord.models.#{model_name.underscore}")}のCSVインポートに成功しました"
    end
end
