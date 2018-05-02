/*
 * Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.wso2.testgrid.automation.executor;

import org.wso2.testgrid.automation.TestAutomationException;
import org.wso2.testgrid.common.DeploymentCreationResult;
import org.wso2.testgrid.common.TestScenario;
import org.wso2.testgrid.common.exception.CommandExecutionException;
import org.wso2.testgrid.common.util.TestGridUtil;

import java.nio.file.Path;

/**
 * Interface for Test executors.
 *
 * @since 1.0.0
 */
public abstract class TestExecutor {

    /**
     * Executes a test based on the given script and the deployment.
     *
     * @param script                   test script
     * @param deploymentCreationResult deployment to run the test script on
     * @throws TestAutomationException thrown when error on executing the given test script
     */
    public abstract void execute(String script, DeploymentCreationResult deploymentCreationResult)
            throws TestAutomationException;

    /**
     * Initialises the test executor.
     * <p>
     * Performs pre-operations required for test execution
     *
     * @param testsLocation location of the test scripts
     * @param testName      test name
     * @param testScenario  {@link TestScenario} instance associated with the test
     * @throws TestAutomationException thrown when error on initialising the test executor
     */
    public abstract void init(String testsLocation, String testName, TestScenario testScenario)
            throws TestAutomationException;

    /**
     * Executes companion scripts.
     * <p>
     * <p>Used for test scenarios that have separate scripts to create or destroy environments</p>
     *
     * @param script                   {@link Path} reference to the script.
     * @param deploymentCreationResult {@link DeploymentCreationResult} object with current environment details.
     * @return The response of script execution.
     * @throws TestAutomationException Throws exception when there is an error executing the script.
     */
    public String executeEnvironmentScript(Path script, DeploymentCreationResult deploymentCreationResult)
            throws TestAutomationException {
        try {
            return TestGridUtil.executeCommand("bash " + script.toString(), null,
                    deploymentCreationResult);
        } catch (CommandExecutionException e) {
            throw new TestAutomationException("Error executing " + script.toString(), e);
        }
    }
}
