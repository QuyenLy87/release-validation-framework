package org.ihtsdo.rvf.execution.service.util;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.concurrent.ConcurrentHashMap;

import javax.annotation.Resource;
import javax.sql.DataSource;

import org.apache.commons.dbcp.BasicDataSource;
import org.springframework.stereotype.Service;

/**
 * A wrapper around {@link org.apache.commons.dbcp.BasicDataSource} that handles dynamic schema changes
 */
@Service
public class RvfDynamicDataSource {

    private String url;
    @Resource(name = "snomedDataSource")
    BasicDataSource basicDataSource;
    private ConcurrentHashMap<String, DataSource> schemaDatasourceMap = new ConcurrentHashMap<>();

    /**
     * Returns a connection for the given schema. It uses an underlying map to store relevant {@link org.apache.commons.dbcp.BasicDataSource}
     * so datasources are reused
     * @param schema the schema for which the connection needs to be returned
     * @return the connection for this schema
     * @throws SQLException
     */
    public Connection getConnection(String schema) throws SQLException {
        if(schemaDatasourceMap.containsKey(schema)){
            return schemaDatasourceMap.get(schema).getConnection();
        }
        else{
            BasicDataSource dataSource = new BasicDataSource();
            dataSource.setUrl(url);
            dataSource.setUsername(basicDataSource.getUsername());
            dataSource.setPassword(basicDataSource.getPassword());
            dataSource.setDriverClassName(basicDataSource.getDriverClassName());
            dataSource.setDefaultCatalog(schema);
            dataSource.setMaxActive(basicDataSource.getMaxActive());
            dataSource.setMaxIdle(basicDataSource.getMaxIdle());
            dataSource.setMinIdle(basicDataSource.getMinIdle());
            dataSource.setTestOnBorrow(basicDataSource.getTestOnBorrow());
            dataSource.setTestOnReturn(basicDataSource.getTestOnReturn());
            dataSource.setTestWhileIdle(basicDataSource.getTestWhileIdle());
            dataSource.setValidationQuery(basicDataSource.getValidationQuery());
            dataSource.setValidationQueryTimeout(basicDataSource.getValidationQueryTimeout());
            dataSource.setMinEvictableIdleTimeMillis(basicDataSource.getMinEvictableIdleTimeMillis());
            dataSource.setTimeBetweenEvictionRunsMillis(basicDataSource.getTimeBetweenEvictionRunsMillis());
            // add to map
            schemaDatasourceMap.putIfAbsent(schema, dataSource);
            return dataSource.getConnection();
        }
    }
    
    
    public void close( String schema) {
    	if ( schema != null) {
    		schemaDatasourceMap.remove(schema);
    	}
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
