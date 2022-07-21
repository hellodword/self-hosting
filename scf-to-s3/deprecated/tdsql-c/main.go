package main

//
//import (
//	"archive/zip"
//	"context"
//	"crypto/sha256"
//	"database/sql"
//	_ "embed"
//	"encoding/hex"
//	"errors"
//	"fmt"
//	_ "github.com/go-sql-driver/mysql"
//	"github.com/tencentyun/scf-go-lib/cloudfunction"
//	"io"
//	"io/ioutil"
//	"log"
//	"os"
//	"os/exec"
//	"path/filepath"
//	"time"
//)
//
//// wget https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.29-linux-glibc2.17-x86_64-minimal.tar.xz
////go:embed assets/mysql-8.0.29-linux-glibc2.17-x86_64-minimal/bin/mysqldump
//var binMysqldump []byte
//
////go:embed assets/mysql-8.0.29-linux-glibc2.17-x86_64-minimal/lib/private/libcrypto.so.1.1
//var binLibcrypto []byte
//
////go:embed assets/mysql-8.0.29-linux-glibc2.17-x86_64-minimal/lib/private/libssl.so.1.1
//var binLibssl []byte
//
//func initAssets(baseDir string) error {
//	err := os.Mkdir(filepath.Join(baseDir, "bin"), 0775)
//	if err != nil && !errors.Is(err, os.ErrExist) {
//		return err
//	}
//
//	err = os.Mkdir(filepath.Join(baseDir, "lib"), 0775)
//	if err != nil && !errors.Is(err, os.ErrExist) {
//		return err
//	}
//
//	err = os.Mkdir(filepath.Join(baseDir, "lib/private"), 0775)
//	if err != nil && !errors.Is(err, os.ErrExist) {
//		return err
//	}
//
//	err = ioutil.WriteFile(filepath.Join(baseDir, "bin/mysqldump"), binMysqldump, 0751)
//	if err != nil {
//		return err
//	}
//	err = ioutil.WriteFile(filepath.Join(baseDir, "lib/private/libcrypto.so.1.1"), binLibcrypto, 0751)
//	if err != nil {
//		return err
//	}
//	err = ioutil.WriteFile(filepath.Join(baseDir, "lib/private/libssl.so.1.1"), binLibssl, 0751)
//	if err != nil {
//		return err
//	}
//	return nil
//}
//
//func verifyEnv() error {
//	if os.Getenv("DB_HOST") == "" || os.Getenv("DB_PORT") == "" || os.Getenv("DB_USER") == "" || os.Getenv("DB_PASS") == "" || os.Getenv("DB_NAME") == "" {
//		return fmt.Errorf("db vars")
//	}
//
//	//if os.Getenv("COS_SECRET_ID") == "" || os.Getenv("COS_SECRET_KEY") == "" || os.Getenv("COS_URL") == "" {
//	//	return fmt.Errorf("cos vars")
//	//}
//	//
//	//if os.Getenv("OSS_ENDPOINT") == "" || os.Getenv("OSS_BUCKET") == "" || os.Getenv("OSS_ACCESSKEY_ID") == "" || os.Getenv("OSS_ACCESSKEY_SECRET") == "" {
//	//	return fmt.Errorf("oss vars")
//	//}
//	//
//	//if _, err := url.Parse(os.Getenv("COS_URL")); err != nil {
//	//	return err
//	//}
//	return nil
//}
//
//func verifyDB() error {
//	db, err := sql.Open("mysql", fmt.Sprintf(
//		"%s:%s@tcp(%s:%s)/%s",
//		os.Getenv("DB_USER"),
//		os.Getenv("DB_PASS"),
//		os.Getenv("DB_HOST"),
//		os.Getenv("DB_PORT"),
//		os.Getenv("DB_NAME")))
//	if err != nil {
//		return err
//	}
//	defer db.Close()
//
//	return db.Ping()
//}
//
//func archive(src, name, dst string) error {
//	d, err := os.Create(dst)
//	if err != nil {
//		return err
//	}
//	defer d.Close()
//	zipWriter := zip.NewWriter(d)
//
//	f0, err := os.Open(src)
//	if err != nil {
//		return err
//	}
//	defer f0.Close()
//
//	w0, err := zipWriter.Create(name)
//	if err != nil {
//		return err
//	}
//
//	_, err = io.Copy(w0, f0)
//	if err != nil {
//		return err
//	}
//
//	err = zipWriter.Close()
//	if err != nil {
//		return err
//	}
//	return nil
//}
//
//func getFileHash(src string) (string, error) {
//	f, err := os.Open(src)
//	if err != nil {
//		return "", err
//	}
//	defer f.Close()
//
//	hash := sha256.New()
//	if _, err := io.Copy(hash, f); err != nil {
//		log.Fatal(err)
//	}
//	sum := hash.Sum(nil)
//
//	return hex.EncodeToString(sum), nil
//}
//
//func backup() error {
//	baseDir := "/tmp"
//
//	{
//		if err := verifyEnv(); err != nil {
//			return err
//		}
//
//		if err := verifyDB(); err != nil {
//			return err
//		}
//
//		if err := initAssets(baseDir); err != nil {
//			return err
//		}
//	}
//
//	dumpExec := filepath.Join(baseDir, "bin/mysqldump")
//	dumpFilename := fmt.Sprintf(
//		"%s-%s.sql",
//		os.Getenv("DB_NAME"),
//		time.Now().Format("20060102150405"),
//	)
//	dumpFilepath := filepath.Join(baseDir, dumpFilename)
//
//	archiveFilename := fmt.Sprintf("%s.zip", dumpFilename)
//	archiveFilepath := filepath.Join(baseDir, archiveFilename)
//
//	// mysqldump
//	{
//		if _, err := exec.Command("bash", "-c",
//			fmt.Sprintf("%s --column-statistics=0 -h %s -P %s -u%s -p%s %s > %s",
//				dumpExec,
//				os.Getenv("DB_HOST"),
//				os.Getenv("DB_PORT"),
//				os.Getenv("DB_USER"),
//				os.Getenv("DB_PASS"),
//				os.Getenv("DB_NAME"),
//				dumpFilepath,
//			)).Output(); err != nil {
//			return err
//		}
//	}
//
//	// hash
//	{
//		hash, err := getFileHash(dumpFilepath)
//		if err != nil {
//			return err
//		}
//
//		dumpFilename = fmt.Sprintf("%s.%s", dumpFilename, hash)
//	}
//
//	// zip
//	{
//		if err := archive(dumpFilepath, dumpFilename, archiveFilepath); err != nil {
//			return err
//		}
//	}
//
//	// cos
//	{
//		err := uploadFile("COS_", fmt.Sprintf("bitwarden/%s", archiveFilename), archiveFilepath)
//		if err != nil {
//			return err
//		}
//		//cosURL, _ := url.Parse(os.Getenv("COS_URL"))
//		//cosClient := cos.NewClient(&cos.BaseURL{BucketURL: cosURL}, &http.Client{
//		//	Timeout: 100 * time.Second,
//		//	Transport: &cos.AuthorizationTransport{
//		//		SecretID:  os.Getenv("COS_SECRET_ID"),
//		//		SecretKey: os.Getenv("COS_SECRET_KEY"),
//		//	},
//		//})
//		//
//		//f, err := os.Open(archiveFilepath)
//		//if err != nil {
//		//	return err
//		//}
//		//defer f.Close()
//		//
//		//_, err = cosClient.Object.Put(
//		//	context.Background(),
//		//	fmt.Sprintf("bitwarden/%s", archiveFilename),
//		//	f,
//		//	nil)
//		//if err != nil {
//		//	return err
//		//}
//
//		//defer resp.Body.Close()
//		//bs, _ := ioutil.ReadAll(resp.Body)
//	}
//
//	// aws
//	{
//		err := uploadFile("AWS_", fmt.Sprintf("bitwarden/%s", archiveFilename), archiveFilepath)
//		if err != nil {
//			return err
//		}
//	}
//
//	// oss
//	{
//		err := uploadFile("OSS_", fmt.Sprintf("bitwarden/%s", archiveFilename), archiveFilepath)
//		if err != nil {
//			return err
//		}
//		//ossClient, err := oss.New(os.Getenv("OSS_ENDPOINT"), os.Getenv("OSS_ACCESSKEY_ID"), os.Getenv("OSS_ACCESSKEY_SECRET"))
//		//if err != nil {
//		//	return err
//		//}
//		//
//		//ossBucket, err := ossClient.Bucket(os.Getenv("OSS_BUCKET"))
//		//if err != nil {
//		//	return err
//		//}
//		//
//		//err = ossBucket.PutObjectFromFile(fmt.Sprintf("bitwarden/%s", archiveFilename), archiveFilepath)
//		//if err != nil {
//		//	return err
//		//}
//	}
//
//	return nil
//}
//
//type DefineEvent struct {
//	// test event define
//	Key1 string `json:"key1"`
//	Key2 string `json:"key2"`
//}
//
//func hello(ctx context.Context, event DefineEvent) (string, error) {
//	if err := backup(); err != nil {
//		return "", err
//	}
//
//	return fmt.Sprintf("%s %s", event.Key1, event.Key2), nil
//}
//
//func main() {
//	// Make the handler available for Remote Procedure Call by Cloud Function
//	cloudfunction.Start(hello)
//}
