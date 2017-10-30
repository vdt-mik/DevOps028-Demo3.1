node ('Slave'){
  String jdktool = tool name: "jdk8", type: 'hudson.model.JDK'
  def mvnHome = tool name: 'maven'
  List javaEnv = [
    "PATH+MVN=${jdktool}/bin:${mvnHome}/bin",
    "M2_HOME=${mvnHome}",
    "JAVA_HOME=${jdktool}"
  ]
  withEnv(javaEnv) {
    stage('Clear & Checkout') {
      cleanWs()
      git url: 'https://github.com/vdt-mik/DevOps028-Demo3.1'
    }
    stage('Test & Build') {
      try {
      sh 'mvn clean test'
      sh 'mvn clean package'
      } catch (e) {
          currentBuild.result = 'FAILURE'
        }    
    }
    stage ('Post') {
      if (currentBuild.result == null || currentBuild.result == 'SUCCESS') {
        archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: true  
        sh 'cp target/Samsara-*.jar .'
      }
    }
  }
  stage('Build db docker image') {
    DB_NAME = sh(
      script: "aws ssm get-parameters --names DB_NAME --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    DB_USER = sh(
      script: "aws ssm get-parameters --names DB_USER --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    DB_PASS = sh(
      script: "aws ssm get-parameters --names DB_PASS --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    def dbImage = docker.build("303036157700.dkr.ecr.eu-central-1.amazonaws.com/db:db-${env.BUILD_ID}","--build-arg DB_NAME=${DB_NAME}, " +
                                    "--build-arg DB_USER=${DB_USER} --build-arg DB_PASS=${DB_PASS} ./app/db/")  
  }
  stage('Push db docker image') {
    docker.withRegistry('https://303036157700.dkr.ecr.eu-central-1.amazonaws.com', 'ecr:eu-central-1:ceb0ba5d-18be-4d4c-8090-1120568d9a14') {
      docker.image("303036157700.dkr.ecr.eu-central-1.amazonaws.com/db:db-${env.BUILD_ID}").push()
    }
  }
  stage('Deploy db in k8s') {
    sh "kubectl rolling-update db --image=303036157700.dkr.ecr.eu-central-1.amazonaws.com/db:db-${env.BUILD_ID}"
  }           
  stage('Build docker image') {
    DB_HOST = sh(
      script: "kubectl describe services db | grep 'LoadBalancer Ingress:' | cut -d':' -f2 | tr -d ' '",
      returnStdout: true
      ).trim()
    DB_PORT = sh(
      script: "aws ssm get-parameters --names DB_PORT --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    DB_NAME = sh(
      script: "aws ssm get-parameters --names DB_NAME --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    DB_USER = sh(
      script: "aws ssm get-parameters --names DB_USER --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    DB_PASS = sh(
      script: "aws ssm get-parameters --names DB_PASS --with-decryption --output text | awk '{print \$4}'",
      returnStdout: true
      ).trim()
    ART_NAME = sh(
      script: "ls ${WORKSPACE}/target | grep jar | grep -v original",
      returnStdout: true
      ).trim()
    def samsaraImage = docker.build("303036157700.dkr.ecr.eu-central-1.amazonaws.com/samsara:samsara-${env.BUILD_ID}","--build-arg DB_HOST=${DB_HOST} --build-arg DB_PORT=${DB_PORT} --build-arg DB_NAME=${DB_NAME}, " +
                                    "--build-arg DB_USER=${DB_USER} --build-arg DB_PASS=${DB_PASS} --build-arg ART_NAME=${ART_NAME} ./app/app/")
  }
  stage('Push app docker image') {
    docker.withRegistry('https://303036157700.dkr.ecr.eu-central-1.amazonaws.com', 'ecr:eu-central-1:ceb0ba5d-18be-4d4c-8090-1120568d9a14') {
      docker.image("303036157700.dkr.ecr.eu-central-1.amazonaws.com/samsara:samsara-${env.BUILD_ID}").push()
    }
  }
  stage('Deploy k8s') {
    sh 'kubectl run --image=303036157700.dkr.ecr.eu-central-1.amazonaws.com/samsara:samsara-${env.BUILD_ID} app --port=9000 --replicas=1'
    sh 'kubectl expose deployment app --port=9000 --type=LoadBalancer'
//    sh 'kops replace --name demo3.k8s.local --state=s3://k8s-demo3 -f app/k8s-cluster.yaml'
//    sh 'kops update cluster --name demo3.k8s.local --state=s3://k8s-demo3 --yes && kops rolling-update cluster'
  }  
/*  stage('Check APP') {
    timeout(time: 1, unit: 'MINUTES') {
      waitUntil {
        try {
          APP_URI = sh(
          script: "aws ssm get-parameters --names APP_URL --with-decryption --output text | awk '{print \$4}'",
          returnStdout: true
          ).trim()
          def response = httpRequest "http://$APP_URI/login" 
          println("Status: "+response.status) 
          println("Content: "+response.content)
          return true
        } catch (Exception e) {
            return false
          }
      }
    }     
  } */
}