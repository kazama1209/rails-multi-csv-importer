class CsvImporter
  def self.run(file, model, headers)
    results = [] # バリデーションチェックに通過した（= DBに取り込み可能な）データを格納する配列
    errors = []  # CSVファイル読み込み中に生じたエラーを格納する配列

    CSV.foreach(file.path, headers: true, skip_blanks: true).with_index(2) do |row, index|
      # ヘッダーの項目に従って各値を切り出し
      row_hash = row.to_hash.slice(*headers.keys)
      attributes = row_hash.transform_keys(&headers.method(:[]))

      # バリデーションチェック（無効な値が入っていた場合はエラーを発生させる）
      instance = model.new(attributes)

      if instance.valid?
        results << attributes
      else
        # 何行目でエラーが生じたのかも記録
        errors.push({ row_number: index, messages: instance.errors.full_messages })
      end

    rescue StandardError => e
      errors.push({ row_number: index, messages: [e] })
      return [], errors
    end

    [results, errors]
  end
end
