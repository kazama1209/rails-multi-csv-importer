class CsvController < ApplicationController
  # フラッシュメッセージを Bootstrap 対応させるための設定
  add_flash_types :success, :info, :warning, :danger
  
  def index; end

  def create
    model_name = params[:model_name]
    model = model_name.constantize

    results = params[:results]

    # results は JSON 形式の配列で渡ってくるので parse が必要
    instances = results.map { |row_json| JSON.parse(row_json) }.map do |attributes|
      model.new(attributes)
    end

    # バルクインサート
    model.import(instances)

    redirect_to csv_index_path, success: set_flash_message(model_name)
  end

  def import
    file = params[:file]
    @model_name = params[:model_name]
    model = @model_name.constantize
    headers = set_headers(@model_name)

    # CsvImporter.run() の返り値は Hash 形式の配列
    @results, @errors = CsvImporter.run(file, model, headers)

    respond_to do |format|
      if @errors.present?
        format.js { render :error }
      else
        format.js { render :success }
      end
    end
  end

  private

    # モデルによって異なるヘッダーを設定
    def set_headers(model_name)
      case model_name
      when "Author"
        author_headers
      when "Book"
        book_headers
      end
    end

    def author_headers
      {
        "名前" => "name",
        "メールアドレス" => "email",
        "生年月日" => "birthdate"
      }
    end

    def book_headers
      {
        "作品名" => "title",
        "価格" => "price",
        "出版日" => "published_date"
      }
    end

    # モデルによって異なるフラッシュメッセージを設定
    def set_flash_message(model_name)
      "#{t("activerecord.models.#{model_name.underscore}")}のCSVインポートに成功しました"
    end
end
