/**
 * Starlake.AI JSQLTranspiler is a SQL to DuckDB Transpiler.
 * Copyright (C) 2024 Andreas Reichel <andreas@manticore-projects.com> on behalf of Starlake.AI
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package ai.starlake.transpiler.schema;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;

public class JdbcResultSetMetaData implements ResultSetMetaData {
  ArrayList<JdbcColumn> columns = new ArrayList<>();
  ArrayList<String> labels = new ArrayList<>();

  public void add(JdbcColumn jdbcColumn, String label) {
    columns.add(jdbcColumn);
    labels.add(label);
  }

  public void clear() {
    columns.clear();
    labels.clear();
  }

  @Override
  public int getColumnCount() throws SQLException {
    return columns.size();
  }

  @Override
  public boolean isAutoIncrement(int column) throws SQLException {
    return columns.get(column).isAutomaticIncrement.equalsIgnoreCase("YES");
  }

  @Override
  public boolean isCaseSensitive(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public boolean isSearchable(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public boolean isCurrency(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public int isNullable(int column) throws SQLException {
    return columns.get(column).isNullable.equalsIgnoreCase("YES") ? columnNullable : columnNoNulls;
  }

  @Override
  public boolean isSigned(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public int getColumnDisplaySize(int column) throws SQLException {
    return columns.get(column).columnSize;
  }

  @Override
  public String getColumnLabel(int column) throws SQLException {
    if (labels.size() > column) {
      String label = labels.get(column);

      return label != null && !label.isEmpty() ? label : columns.get(column).columnName;
    } else {
      return columns.get(column).columnName;
    }
  }

  @Override
  public String getColumnName(int column) throws SQLException {
    return columns.get(column).columnName;
  }

  @Override
  public String getSchemaName(int column) throws SQLException {
    return columns.get(column).scopeSchema;
  }

  @Override
  public int getPrecision(int column) throws SQLException {
    return columns.get(column).columnSize;
  }

  @Override
  public int getScale(int column) throws SQLException {
    return columns.get(column).decimalDigits;
  }

  @Override
  public String getTableName(int column) throws SQLException {
    return columns.get(column).tableName;
  }

  @Override
  public String getCatalogName(int column) throws SQLException {
    return columns.get(column).tableCatalog;
  }

  @Override
  public int getColumnType(int column) throws SQLException {
    return columns.get(column).dataType;
  }

  @Override
  public String getColumnTypeName(int column) throws SQLException {
    return columns.get(column).typeName;
  }

  @Override
  public boolean isReadOnly(int column) throws SQLException {
    // @todo: implement this properly
    return true;
  }

  @Override
  public boolean isWritable(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public boolean isDefinitelyWritable(int column) throws SQLException {
    // @todo: implement this properly
    return false;
  }

  @Override
  public String getColumnClassName(int column) throws SQLException {
    return columns.get(column).typeName;
  }

  @Override
  public <T> T unwrap(Class<T> iface) throws SQLException {
    // @todo: implement this properly
    return null;
  }

  @Override
  public boolean isWrapperFor(Class<?> iface) throws SQLException {
    // @todo: implement this properly
    return false;
  }
}
